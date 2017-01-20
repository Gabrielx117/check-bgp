#!/usr/bin/env python
#coding=utf-8
import pexpect,sys,re,time,threading,os,socket
def connect(loopback,device_type): #telnet device
        if device_type == 'mx960':
                login='ogin:'
        elif device_type== 'ne40':
                login='name:'
        else:
                print ("unknow device type")
                return False
        loginprompt = '[$#>]'
        child = pexpect.spawn('telnet %s' % loopback)
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
def check(cmd,loopback,device_type,keyword,expect_wd):
    #导入参数,分别为:命令文本(多行),设备IP地址,设备类型,过滤关键字,输出等待结束符
        lj=connect(loopback,device_type)
        if lj :
                for c in cmd:
                        lj.sendline(c)
                        time.sleep(0.1)
                if expect_wd == '0':
                    #如果没有特定等待字符,调用时填写 0
                    index = lj.expect(pexpect.TIMEOUT,timeout=1)
                else:
                    #设定特定等待结束符
                    index = lj.expect(expect_wd)
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
cmd_file = sys.argv[1]
loopback = sys.argv[2]
device_type = sys.argv[3]
keyword = sys.argv[4]
expect_wd = sys.argv[5]
username=sys.argv[6]
passwd=sys.argv[7]
mx960_cmd=open(sys.path[0] + "/"+ cmd_file)
if (mx960_cmd == 0):
    print "no list file. please check!"
    sys.exit(1)
#print ('check ip route in list ' + cmd_file)
check(mx960_cmd,loopback,device_type,keyword,expect_wd)
mx960_cmd.close()
