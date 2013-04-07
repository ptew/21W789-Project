//
//  GroupQConnection.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQConnection.h"

@interface GroupQConnection () {
    // Read and write streams
    NSInputStream *readStream;
    NSOutputStream *writeStream;
    CFSocketNativeHandle connectionSocket;
}

@property (strong, nonatomic) NSMutableData* currentMessageToWrite; // Buffer storing text to eventually
                                                                    // send

@property (strong, nonatomic) NSMutableString* currentHeaderBeingRead;
@property (strong, nonatomic) NSMutableString* currentMessageBeingRead;

// Sets up the read and write streams after acquisition
- (void) setUpStreams;
- (void) tryWriting;
- (void) processText: (NSString*) text;
@end

@implementation GroupQConnection

// Acquires i/o streams using the other end's Bonjour service
- (void) connectWithService:(NSNetService *)service {
    // Get the streams
    [service getInputStream:&readStream outputStream:&writeStream];
    
    // Set up the streams
    [self setUpStreams];
}

// Acquires i/o streams using the other end's socket handle
- (void) connectWithSocketHandle:(CFSocketNativeHandle)handle {
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
    // Make sure we got them
    if (readStream != nil && writeStream != nil) {
        [self.delegate connectionDidConnect:self];
    }
    else {
        [self.delegate connectionDidNotConnect:self];
    }
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
    self.currentMessageBeingRead = [[NSMutableString alloc] init];
    
    // Open up the streams for communication
    [readStream open];
    [writeStream open];
}

- (void) disconnectStreams:(BOOL)sendDisconnect {
    if (sendDisconnect) {
        self.currentMessageToWrite = [[NSMutableData alloc] init];
        char disconnectChar = ((char)4);
        NSString *outString = [NSString stringWithFormat:@"%c", disconnectChar];
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
    // Appends the outgoing text after encoding it as ASCII bytes
    unichar delimiter = ((unichar)2);
    unichar endofmessage = ((unichar)3);
    NSString *outString = [NSString stringWithFormat:@"%@%cs%@%c", header, delimiter, message, endofmessage];
    [self.currentMessageToWrite appendData:[outString dataUsingEncoding:NSASCIIStringEncoding]];
    [self tryWriting];
}


// Adds text to the outgoing data buffer
- (void) sendObject: (id) what withHeader: (NSString*) header {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:what];
    // Appends the outgoing text after encoding it as ASCII bytes
    unichar delimiter = ((unichar)2);
    unichar endofmessage = ((unichar)3);
    NSString *headerString = [NSString stringWithFormat:@"%@%co", header, delimiter];
    NSString *endOfMessage = [NSString stringWithFormat:@"%c", endofmessage];
    [self.currentMessageToWrite appendData:[headerString dataUsingEncoding:NSASCIIStringEncoding]];
    [self.currentMessageToWrite appendData:encodedObject];
    [self.currentMessageToWrite appendData:[endOfMessage dataUsingEncoding:NSASCIIStringEncoding]];
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
        if (bytesSent < 0)
            return;
        // Remove the sent bytes from the buffer.
        NSRange range = {0, bytesSent};
        [self.currentMessageToWrite replaceBytesInRange:range withBytes:NULL length:0];
    }
}

// Processes incoming text into messages
- (void) processText:(NSString *)text {
    unichar delimeter = ((unichar)2);
    unichar endofmessage = ((unichar)3);
    unichar buffer[text.length];
    [text getCharacters:buffer];
    for (unsigned int i=0; i<text.length; i++) {
        unichar currentChar = buffer[i];
        if (currentChar == delimeter) {
            self.currentHeaderBeingRead = [NSString stringWithString:self.currentMessageBeingRead];
            [self.currentMessageBeingRead deleteCharactersInRange:NSMakeRange(0, self.currentMessageBeingRead.length)];
        }
        else if (currentChar == endofmessage) {
            NSString *header = [NSString stringWithString:self.currentHeaderBeingRead];
            [self.currentHeaderBeingRead deleteCharactersInRange:NSMakeRange(0, self.currentHeaderBeingRead.length)];
            
            if ([self.currentMessageBeingRead characterAtIndex:0] == 's') {
                NSString *message = [NSString stringWithString:[self.currentMessageBeingRead substringFromIndex:1]];
                [self.delegate connection:self receivedMessage:message withHeader: header];
            }
            else if ([self.currentMessageBeingRead characterAtIndex:0] == 'o') {
                NSString *message = [NSString stringWithString:[self.currentMessageBeingRead substringFromIndex:1]];
                NSData *objectData = [message dataUsingEncoding:NSASCIIStringEncoding];
                [self.delegate connection:self receivedObject:objectData withHeader: header];
            }
            [self.currentMessageBeingRead deleteCharactersInRange:NSMakeRange(0, self.currentMessageBeingRead.length)];
        }
        else {
            [self.currentMessageBeingRead appendFormat:@"%c", currentChar];
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
                
                // Decode the data using ASCII
                NSString *newText = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
                
                unichar lastCharacter = [newText characterAtIndex:newText.length-1];
                unichar disconnect = ((unichar)4);
                if (lastCharacter == disconnect)
                {
                    [self disconnectStreams:FALSE];
                    [self.delegate connectionDisconnected:self];
                }
                // Finished! Process the text
                [self processText: newText];
            }
            break;
        }
        // Here, we need to close the connection
        case NSStreamEventErrorOccurred: {
            [self.delegate connectionDisconnected:self];
            [self disconnectStreams:TRUE];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self.delegate connectionDisconnected:self];
            [self disconnectStreams:TRUE];
            break;
        }
        default: {
            break;
        }
    }
}
@end
