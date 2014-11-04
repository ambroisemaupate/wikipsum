//
//  AppDelegate.swift
//  Wikipsum
//
//  Created by Ambroise Maupate on 03/11/2014.
//  Copyright (c) 2014 Ambroise Maupate. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var wikipsumButton: NSButtonCell!
    @IBOutlet weak var titleContent: NSTextField!
    @IBOutlet weak var characterCount: NSTextField!
    @IBOutlet var extractContent: NSTextView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var error: NSError;
        //var object = NSJSONSerialization.JSONObjectWithData(returnedData, 0, &error);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func loadWikiContent(sender: NSButtonCell) {
        
        self.wikipsumButton.enabled = false;
        
        var apiPath = "http://fr.wikipedia.org/w/api.php?action=query&generator=random&grnnamespace=0&prop=extracts&exchars=500&format=json";
        
        if (self.characterCount.integerValue > 0) {
            apiPath = "http://fr.wikipedia.org/w/api.php?action=query&generator=random&grnnamespace=0&prop=extracts&exchars="+self.characterCount.stringValue+"&format=json";
        }
        
        var url = NSURL(string: apiPath);
        var request = NSURLRequest(URL: url!);
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if (nil != data) {
                var error: NSError?;
                var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                //println(boardsDictionary);
                var query = boardsDictionary.objectForKey("query") as NSDictionary
                var pages = query.objectForKey("pages") as NSDictionary
              
                for (key, value) in pages {
                    
                    var page = pages.objectForKey(key) as NSDictionary
                    //println(page.valueForKey("title"))
                    //println(page.valueForKey("extract"))
                    
                    self.titleContent.stringValue = page.valueForKey("title") as String;
                    
                    self.extractContent.string = self.html2markdown(page.valueForKey("extract") as NSString);
                    
                }
                self.wikipsumButton.enabled = true;
            }
        }
    }
    
    func html2markdown(content: NSString) -> String {
        
        var newContent = content
        
        newContent = self.replace(
            newContent,
            replacement: "**$1**",
            pattern: "<b>([^<]+)</b>")
        
        newContent = self.replace(
            newContent,
            replacement: "*$1*",
            pattern: "<i>([^<]+)</i>")
        
        newContent = self.replace(
            newContent,
            replacement: "\n",
            pattern: "</p>")
        newContent = self.replace(
            newContent,
            replacement: "",
            pattern: "<p>")
        newContent = self.replace(
            newContent,
            replacement: "## $1",
            pattern: "<h2>([^\n]+)</h2>")
        newContent = self.replace(
            newContent,
            replacement: "### $1",
            pattern: "<h3>([^\n]+)</h3>")
        newContent = self.replace(
            newContent,
            replacement: "#### $1",
            pattern: "<h4>([^\n]+)</h4>")
        
        newContent = self.replace(
            newContent,
            replacement: "* $1",
            pattern: "<li>([.]+)</li>")
        newContent = self.replace(
            newContent,
            replacement: "\n",
            pattern: "</ul>")
        newContent = self.replace(
            newContent,
            replacement: "",
            pattern: "<ul[^>]*>")
        
        return newContent as String
    }
    
    func replace(base: NSString, replacement: NSString, pattern: NSString) -> String {
        let regex = NSRegularExpression(
            pattern: pattern,
            options: nil,
            error: nil)
        
        var newString = regex?.stringByReplacingMatchesInString(
            base,
            options: nil,
            range: NSMakeRange(0, base.length),
            withTemplate: replacement)
        
        return newString! as String
    }
}

