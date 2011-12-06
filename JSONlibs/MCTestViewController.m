//
//  MCTestViewController.m
//  JSONlibs
//
//  Created by Junior Bontognali on 6.12.11.
//  Copyright (c) 2011 Mocha Code. All rights reserved.
//

#import "MCTestViewController.h"
#import "JSONKit.h"
#import "SBJson.h"
#import "CJSONDeserializer.h"
#import "NXJsonParser.h"

@implementation MCTestViewController

@synthesize selectedLibraries = _selectedLibraries;
@synthesize selectedFile;
@synthesize hud = _hud;
@synthesize results = _results;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    self.hud = nil;
    self.selectedFile = nil;
    [_results release];
    [_selectedLibraries release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = self.selectedFile;
    
    _results = [[NSMutableDictionary alloc] initWithCapacity:[_selectedLibraries count]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [_hud setLabelText:@"Loading file..."];
    [_hud show:YES];
    [self.view addSubview:_hud];
    
    [self performSelector:@selector(parse) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return !(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_selectedLibraries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [_selectedLibraries objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms", [[_results objectForKey:[_selectedLibraries objectAtIndex:indexPath.row]] floatValue]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - HUD delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud release];
}

#pragma mark - Parser

- (void)parse
{    
    NSError *error = nil;
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:selectedFile ofType:@""];
    NSString *contentFile = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", [error description]);
        return;
    }
    
    //Libs JSONKit, TouchJSON, NextiveJson, SBJSON, NSJSONSerialization
    
    for (NSString *libName in _selectedLibraries) 
    {
        [_hud setLabelText:[NSString stringWithFormat:@"Parsing with %@...", libName]];
        float timeElapsed;
        
        if ([libName isEqualToString:@"JSONKit"]) {
            timeElapsed = [self parseWithJSONKit:contentFile];
        } else if ([libName isEqualToString:@"SBJSON"]) {
            timeElapsed = [self parseWithSBJSON:contentFile];
        } else if ([libName isEqualToString:@"TouchJSON"]) {
            timeElapsed = [self parseWithTouchJSON:contentFile];
        } else if ([libName isEqualToString:@"NextiveJson"]) {
            timeElapsed = [self parseWithTouchJSON:contentFile];
        } else if ([libName isEqualToString:@"NSJSONSerialization"]) {
            timeElapsed = [self parseWithNSJSONSerialization:contentFile];
        }
        NSLog(@"%@ time elapsed -> %f", libName, timeElapsed);
        [_results setValue:[NSNumber numberWithFloat:timeElapsed] forKey:libName];
    }
    
    [_hud hide:YES];
    [self.tableView reloadData];    
}

- (float)parseWithJSONKit:(NSString *)content
{
    NSDate *startTime = [NSDate date];
    id result = [content objectFromJSONString];  
    float elapsedTime = [startTime timeIntervalSinceNow] * -1000;
    if (result == nil)
        return -1.0;
    return elapsedTime;
}

- (float)parseWithSBJSON:(NSString *)content
{
    NSDate *startTime = [NSDate date];
    // Create SBJSON object to parse JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id result = [parser objectWithString:content error:nil];
    float elapsedTime = [startTime timeIntervalSinceNow] * -1000;
    if (result == nil)
        return -1.0;
    return elapsedTime;
}

- (float)parseWithTouchJSON:(NSString *)content
{
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDate *startTime = [NSDate date];
    [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
    float elapsedTime = [startTime timeIntervalSinceNow] * -1000;
    if (error)
        return -1.0;
    return elapsedTime;
}

- (float)parseWithNXJSON:(NSString *)content
{
    NSError *error = nil;
	NSDate *startTime = [NSDate date];
	[NXJsonParser parseString:content error:&error ignoreNulls:NO];
    float elapsedTime = [startTime timeIntervalSinceNow] * -1000;
    if (error)
        return -1.0;
    return elapsedTime;
}

- (float)parseWithNSJSONSerialization:(NSString *)content
{
    NSError *error = nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDate *startTime = [NSDate date];
	id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    float elapsedTime = [startTime timeIntervalSinceNow] * -1000;
    if (result == nil)
        return -1.0;
    return elapsedTime;
}



@end
