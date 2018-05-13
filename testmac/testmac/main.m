//
//  main.m
//  testmac
//
//  Created by Allenboy on 2018/5/13.
//  Copyright © 2018年 Allenboy. All rights reserved.
//
#import "RDProcess.h"
#include <mach-o/dyld.h>
#import <Cocoa/Cocoa.h>
static void print_usage(const char *prog_name)
{
    printf("Usage: %s [pid]\nIf no pid specified, getpid() is used\n\n", prog_name);
}
void pid( pid_t pid);
int main(int argc, const char * argv[]) {
    
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    for(int i=0;i<runningApps.count;i++){
        NSRunningApplication *app = [runningApps objectAtIndex:i];
        //进程 pid
        NSLog(@"----------------------------------------进程 pid：%d--------------------------------------", app.processIdentifier);
        pid(app.processIdentifier);
//        //进程的url
//        NSLog(@"进程 bundleURL：%@", app.bundleURL);
//        NSLog(@"进程 bundleIdentifier：%@", app.bundleIdentifier);
//        // 可执行文件 url
//        NSLog(@"进程 executableURL：%@", app.executableURL);
//        NSLog(@"进程 executableArchitecture：%ld", (long)app.executableArchitecture);
//        //进程名称
//        NSLog(@"进程 name：%@", app.localizedName);
    }
    
//    pid_t pid = (-1);
//    if (argc < 2) {
//        print_usage(argv[0]);
//        pid = getpid();
//    } else {
//       // pid = strtol(argv[1], NULL, 10);  //字符串转 类型为 long int 型  最后一个为几进制
//    }
//
   
   // [proc release];

    //return NSApplicationMain(argc, argv);
}
void pid( pid_t pid){
    RDProcess *proc = [[RDProcess alloc] initWithPID: 75712];
    if (!proc) {
        NSLog(@"Could not create RDProcess with invalid PID (%d)", pid);
        return;
    }
    NSLog(@"Proc general: %@", proc);
    
    NSLog(@"PID: %d", proc.pid);
    NSLog(@"Name: %@", proc.processName);
    NSLog(@"Bundle ID: %@", proc.bundleID);
    NSLog(@"Bundle URL: %@", proc.bundleURL);
    NSLog(@"Executable URL: %@", proc.executableURL);
    NSLog(@"Owner: %@, %@ (%d)", proc.ownerUserName, proc.ownerFullUserName, proc.ownerUserID);
    
    NSDictionary *tmp = proc.ownerGroups;
    if (tmp.count > 0) {
        NSMutableString *owner_groups = [[NSMutableString alloc] init];
        [tmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [owner_groups appendFormat:@"%@(%@), ", obj, key];
        }];
        
        NSLog(@"Owner groups (%lu): %@",
              [tmp allKeys].count, [owner_groups substringToIndex: owner_groups.length-2]);
        // [owner_groups release];
    }
    
    NSLog(@"Sandboxed by OS X (unreliable): %@", proc.isSandboxedByOSX ? @"YES" : @"NO");
    NSLog(@"Sandbox container: %@", proc.sandboxContainerPath);
    
    NSArray *paths = @[
                       @"/usr/bin",
                       @"~/Library/Fonts",
                       @"~/Library/Colors",
                       @"~/Desktop",
                       @"/",
                       @"~/Library/Container/com.apple.Preview/Data/Library",
                       proc.executablePath
                       ];
    if (proc.sandboxContainerPath) {
        paths = [paths arrayByAddingObject: proc.sandboxContainerPath];
    }
    [paths enumerateObjectsUsingBlock: ^(id path, NSUInteger idx, BOOL *stop){
        NSLog(@"Sandbox file permissions {%@%@} for [%@]:\t",
              [proc canReadFileAtPath: [path stringByExpandingTildeInPath]] ? @"R" : @"-",
              [proc canWriteToFileAtPath: [path stringByExpandingTildeInPath]] ? @"W" : @"-",
              path);
    }];
    
    NSLog(@"Arguments: %@", proc.launchArguments);
    NSLog(@"Environment: %@", proc.environmentVariables);
    
    // proc.processName = [proc.processName stringByAppendingString: @" (RDProcess)"];
    
    NSLog(@"All processes with the same Bundle ID:");
    [RDProcess enumerateProcessesWithBundleID: proc.bundleID
                                   usingBlock:^(id process, NSString *bundleID, BOOL *stop){
                                       NSLog(@"\t* %@", process);
                                   }];
    NSLog(@"And again, here they are:");
    NSLog(@"%@", [RDProcess allProcessesWithBundleID: proc.bundleID]);
    NSLog(@"The youngest process: %@", [RDProcess youngestProcessWithBundleID: proc.bundleID]);
    NSLog(@"The oldest process: %@", [RDProcess oldestProcessWithBundleID: proc.bundleID]);
}
