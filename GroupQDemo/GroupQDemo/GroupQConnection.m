//
//  GroupQConnection.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQConnection.h"
#import "GroupQMusicCollection.h"

@interface GroupQConnection () {
    // Read and write streams
    NSInputStream *readStream;
    NSOutputStream *writeStream;
    CFSocketNativeHandle connectionSocket;
    int numberOfBytesToRead;
    int bytesRead;
}

@property (strong, nonatomic) NSMutableData* currentMessageToWrite; // Buffer storing text to eventually
                                                                    // send

@property (strong, nonatomic) NSMutableString* currentHeaderBeingRead;
@property (strong, nonatomic) NSMutableString* currentTypeBeingRead;
@property (strong, nonatomic) NSMutableData* currentMessageBeingRead;

// Sets up the read and write streams after acquisition
- (void) setUpStreams;
- (void) tryWriting;
- (void) processText: (NSData*) data;
@end

@implementation GroupQConnection

// Acquires i/o streams using the other end's Bonjour service
- (void) connectWithService:(NSNetService *)service {
    NSLog(@"GC Connecting to service %@", service.name);
    // Get the streams
    [service getInputStream:&readStream outputStream:&writeStream];
    
    // Set up the streams
    [self setUpStreams];
}

// Acquires i/o streams using the other end's socket handle
- (void) connectWithSocketHandle:(CFSocketNativeHandle)handle {
    NSLog(@"GC Connecting to a client.");
    connectionSocket = handle;
    // Convert the NSStreams to CFStreams
    CFReadStreamRef readRef;
    CFWriteStreamRef writeRef;
    
    // Acquire the streams
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readRef, &writeRef);
    
    
    readStream = (NSInputStream*)CFBridgingRelease(readRef);
    writeStream = (NSOutputStream*)CFBridgingRelease(writeRef);
    
    // Set them up
    [self setUpStreams];
}

- (void) setUpStreams {
    NSLog(@"GC Setting up streams.");
    // Make sure we got them
    // Set the stream delegates
    readStream.delegate = self;
    writeStream.delegate = self;
    
    // Schedule their polling in the run loop
    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    
    // Set up buffers
    self.currentMessageToWrite = [[NSMutableData alloc] init];
    self.currentHeaderBeingRead = [[NSMutableString alloc] init];
    self.currentTypeBeingRead = [[NSMutableString alloc] init];
    self.currentMessageBeingRead = [[NSMutableData alloc] init];
    numberOfBytesToRead = -1;
    bytesRead = 0;
    
    // Open up the streams for communication
    [readStream open];
    [writeStream open];
    
    if (readStream != nil && writeStream != nil) {
        NSLog(@"GC Connected!");
        [self.delegate connectionDidConnect:self];
    }
    else {
        NSLog(@"GC Could not connect.");
        [self.delegate connectionDidNotConnect:self];
    }
}

- (void) disconnectStreams:(BOOL)sendDisconnect {
    NSLog(@"GC Disconnecting streams");
    if (sendDisconnect) {
        char delimiter = ((char)2);
        NSString *outString = [NSString stringWithFormat:@"terminate%c", delimiter];
        [self.currentMessageToWrite appendData:[outString dataUsingEncoding:NSASCIIStringEncoding]];
        [self tryWriting];
    }
    
    [readStream close];
    [writeStream close];
    [readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

// Adds text to the outgoing data buffer
- (void) sendMessage: (NSString*) message withHeader: (NSString*) header {
    NSLog(@"GC Sending message with header %@", header);
    // Appends the outgoing text after encoding it as ASCII bytes
    char delimiter = ((char)2);
    NSData *messageBytes = [message dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *headerString = [NSString stringWithFormat:@"%@%cs%c%d%c", header, delimiter, delimiter, messageBytes.length, delimiter];
    [self.currentMessageToWrite appendData:[headerString dataUsingEncoding:NSASCIIStringEncoding]];
    [self.currentMessageToWrite appendData:messageBytes];
    [self tryWriting];
}


// Adds text to the outgoing data buffer
- (void) sendObject: (id) what withHeader: (NSString*) header {
    NSLog(@"GC Sending object with header %@", header);
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:what];
    // Appends the outgoing text after encoding it as ASCII bytes
    char delimiter = ((char)2);
    NSString *headerString = [NSString stringWithFormat:@"%@%co%c%d%c", header, delimiter, delimiter, encodedObject.length, delimiter];
    [self.currentMessageToWrite appendData:[headerString dataUsingEncoding:NSASCIIStringEncoding]];
    [self.currentMessageToWrite appendData:encodedObject];
    [self tryWriting];
}

// Attempts to send text
- (void) tryWriting {
    if ([writeStream streamStatus] == NSStreamStatusClosed)
        return;
    // Convert the outgoing bytes to C form. See how many there are
    uint8_t *readBytes = (uint8_t *)[self.currentMessageToWrite mutableBytes];
    int data_len = [self.currentMessageToWrite length];
    // Only write if there is stuff to write
    if (data_len > 0) {
        // Send a maximum of 1024 bytes (1kb)
        unsigned int len = ((data_len >= 1024) ?
                            1024 : (data_len));
        
        // Initialize our send buffer
        uint8_t buf[len];
        
        // Copy over the bytes that we're going to be sending
        (void)memcpy(buf, readBytes, len);
        // Send the bytes. len will store the amount of bytes that were actually sent.
        NSInteger bytesSent = [writeStream write:(const uint8_t *)buf maxLength:len];
        NSLog(@"GC Wrote %d bytes to stream", bytesSent);
        if (bytesSent < 0)
            return;
        // Remove the sent bytes from the buffer.
        NSRange range = {0, bytesSent};
        [self.currentMessageToWrite replaceBytesInRange:range withBytes:NULL length:0];
    }
}

// Processes incoming text into messages
- (void) processText:(NSData *)data {
    char delimeter = ((char)2);
    NSString *delimString = [NSString stringWithFormat:@"%c", delimeter];
    char buffer[data.length];
    [data getBytes:buffer];
    for (unsigned int i=0; i<data.length; i++) {
        char currentChar = buffer[i];
        char tempBuffer[1];
        tempBuffer[0] = currentChar;
        if (numberOfBytesToRead == -1) {
            NSString *character = [[NSString alloc] initWithBytes:tempBuffer length:1 encoding:NSASCIIStringEncoding];
            if ([character isEqualToString:delimString]) {
                if (self.currentHeaderBeingRead.length == 0) {
                    self.currentHeaderBeingRead = [[NSMutableString alloc] initWithData:self.currentMessageBeingRead encoding:NSASCIIStringEncoding];
                    if ([self.currentHeaderBeingRead isEqualToString:@"terminate"]) {
                        [self disconnectStreams:NO];
                        [self.delegate connectionDisconnected:self];
                    }
                    self.currentMessageBeingRead = [[NSMutableData alloc] init];
                }
                else if(self.currentTypeBeingRead.length == 0) {
                    self.currentTypeBeingRead = [[NSMutableString alloc] initWithData:self.currentMessageBeingRead encoding:NSASCIIStringEncoding];
                    self.currentMessageBeingRead = [[NSMutableData alloc] init];
                }
                else if(numberOfBytesToRead == -1) {
                    NSString *bytesToRead = [[NSString alloc] initWithData:self.currentMessageBeingRead encoding:NSASCIIStringEncoding];
                    numberOfBytesToRead = [bytesToRead integerValue];
                    self.currentMessageBeingRead = [[NSMutableData alloc] init];
                }
            }
            else {
                [self.currentMessageBeingRead appendBytes:tempBuffer length:1];
            }
        }
        else {
            if (bytesRead < numberOfBytesToRead) {
                [self.currentMessageBeingRead appendBytes:tempBuffer length:1];
                bytesRead++;
            }
            if (bytesRead >= numberOfBytesToRead) {
                NSLog(@"GC Received Data Packet");
                NSString *header = [NSString stringWithString:self.currentHeaderBeingRead];
                if([self.currentTypeBeingRead isEqualToString:@"s"]) {
                    NSString *message = [[NSString alloc] initWithData:self.currentMessageBeingRead encoding:NSASCIIStringEncoding];
                    [self.delegate connection:self receivedMessage:message withHeader:self.currentHeaderBeingRead];
                }
                else {
                    NSData *object = [NSData dataWithData:self.currentMessageBeingRead];
                    [self.delegate connection:self receivedObject:object withHeader:header];
                }
                bytesRead = 0;
                numberOfBytesToRead = -1;
                self.currentHeaderBeingRead = [[NSMutableString alloc] init];
                self.currentTypeBeingRead = [[NSMutableString alloc] init];
                self.currentMessageBeingRead = [[NSMutableData alloc] init];
            }
        }
    }
}

// Handles events from the streams
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        // Specific to the write stream
        case NSStreamEventHasSpaceAvailable: {
            [self tryWriting];
            break;
        }
        // Specific to the input stream
        case NSStreamEventHasBytesAvailable: {
            // Set up buffers to hold the incoming data
            NSMutableData *incomingData = [[NSMutableData alloc] init];
            uint8_t buffer[1024];
            
            // Read in the data
            unsigned int len = 0;
            len = [readStream read:buffer maxLength:1024];
            
            // Only process data when we have some
            if (len > 0) {
                // Add the data to the buffer
                [incomingData appendBytes: buffer length: len];
                
                // Finished! Process the text
                [self processText: incomingData];
            }
            break;
        }
        // Here, we need to close the connection
        case NSStreamEventErrorOccurred: {
            [self disconnectStreams:TRUE];
            [self.delegate connectionDisconnected:self];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self disconnectStreams:NO];
            [self.delegate connectionDisconnected:self];
            break;
        }
        default: {
            break;
        }
    }
}

- (void) setDJ:(bool)yesIfDJ {
    isDJ = yesIfDJ;
}

- (BOOL) isDJ {
    return isDJ;
}
@end
