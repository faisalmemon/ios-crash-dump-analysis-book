//
//  ViewController.h
//  icdab_open
//
//  Created by Faisal Memon on 07/10/2020.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *fileNameTextFieldOutlet;


- (IBAction)openButtonAction:(id)sender;

@end

