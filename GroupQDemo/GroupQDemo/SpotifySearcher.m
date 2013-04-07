//
//  SpotifySearcher.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifySearcher.h"

@interface SpotifySearcher ()
@property (strong, nonatomic) NSMutableArray *parsedData;
@property (strong, nonatomic) SpotifyQueueItem *currentItem;
@end

@implementation SpotifySearcher

- (SpotifySearcher *) init {
    self = [super init];
    self.spotifySearchURL = [NSURL alloc];
    self.spotifySearchURL = [NSURL URLWithString:@"http://ws.spotify.com/search/1/album?q="];
    return self;
}

/*
 Opens a search at a given URL and adds the url to the list of open searches currently being completed. When the search is done it fires a response elsewhere.
 Returns a bool of if the open was preformed succesfully.
*/
- (void)search:(NSString *)query{
    NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"http://ws.spotify.com/search/1/track?q="];
    NSLog(query);
    [searchString appendString:query];
    
    NSURL *newSearch = [NSURL alloc];
    newSearch = [NSURL URLWithString:searchString];
    
    //returns the initalized connection.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:newSearch] delegate:self];
    
    //start the connection.
    [connection start];
}

+ (SpotifySearcher *) sharedSearcher {
    static SpotifySearcher *sharedSearcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearcher = [[SpotifySearcher alloc] init];
    });
    return sharedSearcher;
}
#pragma mark NSURLConnection Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //debuging
    NSLog(@"recieved data");
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", htmlString);
    
    //xml parser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    //do something with the user so we know who to send the info to.
    //puts the user in the parsers map so when the objects are parsed the data can be returned to the user who sent the request.
    [parser setDelegate:self];
    [parser parse];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Failed with error");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
}

#pragma mark NSXMLParser Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    NSLog(@"Starting element %@", elementName);
    //NSLog(@"%@", [[[attributeDict keyEnumerator] allObjects] objectAtIndex:0]);
    
    if([elementName isEqualToString:@"tracks"]){
        self.parsedData = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"track"]){
        self.currentItem = [[SpotifyQueueItem alloc] init];
    }
    else if([elementName isEqualToString:@"name"]){
        //add name to current item
    }
    else if([elementName isEqualToString:@"artist"]){
        //add artist to current item
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"track"]){
        //add the item to parsedData
    }
    else if([elementName isEqualToString:@"tracks"]){
        //the parser has finnished parsing the xml and we can return the results via the delegate.
        //[self.delegate searchReturnedResults:results];
    }
}
@end
