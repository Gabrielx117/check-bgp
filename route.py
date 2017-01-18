#!/usr/bin/env python
#coding=utf-8
import pexpect
import sys
import re
import time
import threading
import os
import socket

def connect(loopback,device_type):
        username='xiayu'
        passwd='tjgwbn123'
        if device_type == 'mx960':
                login='ogin:'
        elif device_type== 'ne40':
                login='name:'
        else:
                print ("unknow device type")
                return False
        loginprompt = '[$#>]'
        child = pexpect.spawn('telnet %s' % hostip)
        index = child.expect([login, "(?i)Unknown host", pexpect.EOF, pexpect.TIMEOUT])
        if (index == 0) :
            child.sendline(username)
            index = child.expect(["[pP]assword", pexpect.EOF, pexpect.TIMEOUT])
            child.sendline(passwd)
            child.expect(loginprompt)
            if (index == 0):
                    return child
            else:
                    print "telnet login failed, due to TIMEOUT or EOF"
                    child.close(force=True)
                    return False
        else:
            print "telnet login failed, due to TIMEOUT or EOF"
            child.close(force=True)
            return False
def check(loopback,device_type,cmd,keyword):
        #loginprompt = '[$#>]'
        lj=connect(loopback,device_type)
        if lj :
                for c in cmd:
                        lj.sendline(c)
                        time.sleep(0.1)
                #index = lj.expect(pexpect.EOF)
                index = lj.expect(pexpect.TIMEOUT,timeout=1)
                if (index == 0):
                        lj.content = lj.before.split('\r')
                        lj.close()
        else:
                print "get info fail. please check!"
                sys.exit(1)
        result=[]
        for line in lj.content:
                if keyword in line:
                    l= line.strip().split()
                    result.append(l[0])
        for s in result:
                print s
n = sys.argv[1]
n= int(n)
m = sys.argv[2]
m=int(m)
for i in range (n,m):
    i=str(i)
    mx960_cmd=open(sys.path[0] + "/mx960.cmd." + i)
    if (cmd == 0):
        print "no list file. please check!"
        sys.exit(1)
    print ('check ip route in list' + i)
    check('220.113.135.52','mx960',mx960_cmd,'metric 1')
    mx960_cmd.close()
