//
//  ViewController.m
//  icdab_open
//
//  Created by Faisal Memon on 07/10/2020.
//

#import "ViewController.h"
#import "objc/message.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)openFile:(NSString*)webAddress
{
    NSURL *url = [NSURL URLWithString:webAddress];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openButtonAction:(id)sender {
    /*
     In order to compile, we require:
     - Enable Strict Checking of objc_mesgSend Calls set to
        No (non-default value)
     - an Intel Mac with Xcode
     - Build Active Architecture Only set to YES for Release
       (non-default value)
     */
    objc_msgSend(self,
                 @selector(openFile:),
                 self.fileNameTextFieldOutlet.stringValue);
}
@end
