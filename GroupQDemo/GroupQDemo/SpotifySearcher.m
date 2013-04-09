//
//  SpotifySearcher.m
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifySearcher.h"

@interface SpotifySearcher ()
//The completed items parsed out of the returned XML
@property (strong, nonatomic) NSMutableArray *parsedData;

//The item currently being parsed.
@property (strong, nonatomic) SpotifyQueueItem *currentItem;

//Object used to build datafields out of character is the parser.
@property (strong, nonatomic) NSMutableString *buildString;

//Parser used to build queue items from returned xml
@property (strong, nonatomic) NSXMLParser *parser;

//This object is used to ammass all of the http data if it is sent in multiple packets.
@property (strong, nonatomic) NSMutableData *httpData;

//The current state of the parser used in between tags.
@property ParserState parserState;
@end


@implementation SpotifySearcher

+ (SpotifySearcher *) sharedSearcher {
    static SpotifySearcher *sharedSearcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearcher = [[SpotifySearcher alloc] init];
    });
    return sharedSearcher;
}

//See header file for details about implementation.
- (void)search: (NSString *)query{
    NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"http://ws.spotify.com/search/1/track?q="];
    
    NSString *formattedQuery = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
     
    [searchString appendString:formattedQuery];
    
    NSURL *newSearch = [NSURL alloc];
    newSearch = [NSURL URLWithString:searchString];
    
    self.httpData = [[NSMutableData alloc] init];
    
    //returns the initalized connection.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:newSearch] delegate:self];
    
    //start the connection.
    [connection start];
}

#pragma mark NSURLConnection Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.httpData appendData:data];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"The connection failed with error %@", error);
}

/*
 This method is called when the http request has been completed and it is time for the parser
 to begin running on the returned XML.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //xml parser
    self.parser = [[NSXMLParser alloc] initWithData:self.httpData];
    [self.parser setDelegate:self];
    [self.parser parse];
}

#pragma mark NSXMLParser Methods

/* This method is called at the beginning of each start xml tag.
 
 - if the tag is tracks then the xml is at the start of the response so parsed data is
 reinitilized.
 
 - if the tag is track then the xml is at the start of a new spotifyQueueItem and the current
 item field is reinitallized to take in the new arguments. Also the parser state is set to
 track to expect the track name to come next.
 
 - if the tag is artist, album, or length, then the parser state is set respectively. This allow
 the name tag to know which field is is referring to so the parsed characters can be added.
 
 - if the tag is name then the following characters refer to the data linked with the current 
 state of the parser. Therefore the build string is reinitalized so the parsed characters
 can be added.
 
*/ 
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if([elementName isEqualToString:@"tracks"]){
        self.parsedData = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"track"]){
        self.currentItem = [[SpotifyQueueItem alloc] init];
        self.currentItem.trackURI = [NSURL URLWithString:(NSString*)[attributeDict objectForKey:@"href"]];
        self.parserState = TRACK;
    }
    else if([elementName isEqualToString:@"name"]){
        self.buildString = [[NSMutableString alloc] init];
    }
    else if([elementName isEqualToString:@"artist"]){
        self.parserState = ARTIST;
    }
    else if([elementName isEqualToString:@"album"]){
        self.parserState = ALBUM;
    }
    else if([elementName isEqualToString:@"length"]){
        self.parserState = LENGTH;
        self.buildString = [[NSMutableString alloc] init];
    }
}

// adds characters parsed to the build string
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if(self.parserState != NONE){
        [self.buildString appendString:string];
    }
}

/* This method is called at the end of every xml tag.
 
 - based on the parser state enum the build string is added to the specified property of the
 current item being built.
 
 - If the end element is track then the newly created current item is added to the list of parsed
 data objects.
 
 - If the end element is tracks then the newly created parsed datafield is done being created.
 The delegate then calls the Search Returned Results method. After it is done, the parser is
 reset to nil.
*/
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"track"]){
        [self.parsedData addObject:self.currentItem];
    }
    else if ([elementName isEqualToString:@"name"]){
        switch (self.parserState) {
            case TRACK:
                self.currentItem.title = [self.buildString copy];
                break;
            case ALBUM:
                self.currentItem.album = [self.buildString copy];
                break;
            case ARTIST:
                self.currentItem.artist = [self.buildString copy];
                break;
            default:
                break;
        }
    self.parserState = NONE;
    }
    else if ([elementName isEqualToString:@"length"]){
        self.currentItem.length = [self.buildString doubleValue];
        self.parserState = NONE;
    }
    else if ([elementName isEqualToString:@"tracks"]){
        [self.delegate searchReturnedResults:self.parsedData];
    }
    parser = nil;
}

//resets the parser to nil just incase. This method is not always called as one would expect.
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    parser = nil;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    parser = nil;
}
@end
