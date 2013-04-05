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

// Sets up the read and write streams after acquisition
- (void) setUpStreams;
- (void) tryWriting;
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
    // Open up the streams for communication
    [readStream open];
    [writeStream open];
}

- (void) disconnectStreams:(BOOL)sendDisconnect {
    if (sendDisconnect) {
        self.currentMessageToWrite = [[NSMutableData alloc] init];
        char disconnectChar = ((char)4);
        [self sendText:[NSString stringWithFormat:@"%c", disconnectChar]];
    }
    
    [readStream close];
    [writeStream close];
    [readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

// Adds text to the outgoing data buffer
- (void) sendText: (NSString*) text {
    // Appends the outgoing text after encoding it as ASCII bytes
    [self.currentMessageToWrite appendData:[text dataUsingEncoding:NSASCIIStringEncoding]];
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
        NSLog(@"Wrote %d bytes to the buffer", bytesSent);
        // Remove the sent bytes from the buffer.
        NSRange range = {0, bytesSent};
        [self.currentMessageToWrite replaceBytesInRange:range withBytes:NULL length:0];
    }
}
// Handles events from the streams
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"Stream event!");
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
                // Finished! Send the processed text to our delegate
                [self.delegate connection:self receivedText:newText];
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
