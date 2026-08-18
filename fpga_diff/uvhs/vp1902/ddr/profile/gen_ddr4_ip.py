#!/bin/env python3
import re
import json
import sys, os, stat, shutil
import subprocess
from optparse import OptionParser

ip32_inline = '''

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Univista"
`pragma protect encrypt_agent_info = "univista-isg uv_enc 2023.08.25-0fea5ec"
`pragma protect data_method = "aes128-cbc"

`pragma protect key_keyowner = "Univista"
`pragma protect key_keyname = "UV-ENC-RSA-1"
`pragma protect key_method = "RSA"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
bpBBDspU+n0GMInBRFZEAJjL42Adc/9tZUosGuvhu8EIzKTdFIKHyL3MjfjA1YypTceERzm9/nC+
I5SquzAnjaK3KyS5G9h7OqYXKtfo9VT7Aw+tCAMglBYlUtcgCqa/kVZO+fEo+PlJRGfaR0ZvkvT2
3YZ4hAEx1ZzJkjuoaPJ2LsRQKCTVIyqvVFZ2DfxIiSkjmAlRn0wWnQWG6t97SxZWgOeWbHZWkg3W
5J8ohvGsvk6uIHTWKvEvG4UJXDi0qu6FgLOM5Bfc7aTta5yd3+8/8zsdlsTlQfpPuaJRtD6lPGki
zXyse+6hRKsjW1ixN/RRckaIVuNAGrGb9o1aWg==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 544)
`pragma protect data_block
Av34YxS3dJfbTT+wQZdXunQE2Z2yvDj+x25MhS2/7GesQj3uXwXXiCx2aVvXduj2NV/TLKltB4+w
LH6din6lgTjr8r6JtiCkDHgNeIoBzFky4H4e5bPkiJNOFb/Dd5eIRTyR/P2PWphtsKRkVthrWYtW
mB+mgGJ0+xtGbWaGyCGr2UiJT+xNIwN4xseDpsKErYOxd4AAW9BOqLEMks9nEeQPmJ9WGGGEZF8c
jmxa1hBKNM09KUPL2acpi9GQJagMj2mlCsgMoQ238rRkbKZVFJjjMYuhHg6i9AmT0+WD8n4/RJVJ
r3MF9GCeyH5+rzWEg4ekLPOScyUJ4z5vzyk9QJQnvEwnNgsT13EA5PdW2X3K8CvHiDICIwDDgCgW
hNfxd2j/VB2NxrXkmoEg/UO+FXdVXVuhkEhFJIMZwI9wsgwve07ExWfMVAVKgpctMuEDKutaq4aT
RIX3H7iB9A5VOpDOKVzFMz4NOnENbMrd4BhAWZwB+nnk+tIum9cm78JrUK1e6GAfF9hSwk5ouvLF
10FkMFWF84r5ty01B7ES3FsFNBG2XiIaBfBaAEIO4qKkOBJrSqYAR7PTaO48gTDn+vIBoO9tZAj1
bhz8dr2e5NrjwmYV4TLFxe6iBGKr1tLi3DV7JkB7IsyKhP0Z+6XgnZOLmZesMUh0VyhKLGFugz+N
7qk9cBUMoekqnctqFvu2y2brMNiK6VOqMxbUt2CGPJK3tEUiAKCYQxjzhbTvMS8=

`pragma protect end_protected

'''
ip_inline = '''

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Univista"
`pragma protect encrypt_agent_info = "univista-isg uv_enc 2023.08.25-0fea5ec"
`pragma protect data_method = "aes128-cbc"

`pragma protect key_keyowner = "Univista"
`pragma protect key_keyname = "UV-ENC-RSA-1"
`pragma protect key_method = "RSA"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
PfZSMlwY0/PT3AyeTNox03PSWcea5/WgEsyNRml83jLvaspFB9v9Yodf0Z8JKjr/nYlADIvtFITi
6WSzs6bSl3kgfhX0tI+vW14fjdrDVKFHeM8kwehtgCu67hffov3csGs9EsRcINS2nbNMjAyJ4RpT
i/IQVy7bDAHPD73RJtbq3kqa452l5mONxLKtGdaqFsw40qrO3VbgXziCdSFwrssEZlNyLjnzgvVI
i93ZUX+5PJugPz9p1Jt8/yVZQJ1ntVG6dqhOdqwSSz5M9K9QB2Qki13w3rsNFjJN+qq3YujCq+gu
jLzPA7rNMUo3/tMyImRCCqyHb8qixF05hu815A==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 528)
`pragma protect data_block
P7q6jql6BIwxKLiHFn+umf6ugxDz8HUZ1P6bpeb+GgmeZU0koHdcoMWIMV5z9SG+45SFf4iOFX0r
Kgrp9fCrrmYkZ6KjXRE2sbyGzXE12CE6SDstvxYEglktrf910SNa4OMjVRivO2xHGDIqUUJxVxnN
XeziDez9IidwJbfkcyGcjQm4/C01E9xPyH29bw/vNl4INF7CSWEbnfSV/Z99vIgNg7VFGlik3nPh
bGxPgjtPAlx41t/H2fdbBx58WII22I4U8qangPiG4SjfyX8Ss7iNIqx4x2mQzZQvOAHZMD5KFhVh
IzVJkF+Y1hBHxsHabWLsPyYS0PcjQry2pe8NGiedwHKj5q/IcJM9liB4ekheLACNHNDVOLNPhM5w
r3ZOM4boWDaoYfEUPlUX761aR6h/dbFe95Ev9bidPB03egw+8E9WYT8WKhNfsMIs8D8L1KSJtItg
mn+11whWEr0hvbvdwUEbx7ANB/5uDxHjh4nrLuBlWOx9PkymoOHvV4NzJzYwaG4idXV9rTrE9FSd
nnGnViD6YE+pZe4B5ajAYo+D/TP1GMP02vZzzCiEVIrkJiE3KHt34DAnLRfU6wWZuc1gHiRTZFeQ
0eQWPYheJzNzgpsscaPKAuOhs8y1t+W56Pp/bTmqfXgy3x+wNYXBrdCPPTeMtVgS8GgrIu/Mf14A
+ErDLMkeIDqUhQ4Ojpb67DTpQk6taVD95uH5sMEgwA==

`pragma protect end_protected

'''

def gen_dcp(d_json):
    if(not os.path.exists(d_json["IP_LOCATION"])):
        raise Exception('Error: Cannot find %s'%d_json["IP_LOCATION"]);


    ip_name = d_json["IP_NAME"];
    proj_dir = 'proj_'+ip_name;
    os.mkdir(proj_dir);
    os.chdir(proj_dir);
    f_runme = open('run.csh', 'w');
    #f_runme.write("#!/bin/tcsh\n");
    f_runme.write("vivado -mode batch -source ./run.tcl");
    f_runme.close();
    os.chmod('run.csh', stat.S_IRWXU);

    f_tcl = open('run.tcl', 'w');
    for conf_field in d_json['CONFIG_FIELD']:
        f_tcl.write("set %s %s\n"%(conf_field, d_json[conf_field]));	 	
    f_tcl.write("set %s %s\n"%("IP_NAME", d_json["IP_NAME"]));
    f_tcl.write("set %s %s\n"%("IP_LOCATION", d_json["IP_LOCATION"]));
    f_tcl.write("set %s %s\n"%("PLATFORM_PART", d_json["PLATFORM_PART"]));
    #f_tcl.write("exec /bin/bash %s/script/ip_rev_gen.sh\n"%(d_json["IP_LOCATION"])); 
    f_tcl.write("source %s/uvw_bd.tcl\n"%(d_json["IP_LOCATION"])); 
    f_tcl.write("run_bd $ADDR_WIDTH $DATA_WIDTH $ID_WIDTH $WR_OUTSTANDING $RD_OUTSTANDING $ECC_EN $IP_LOCATION $PLATFORM_PART $IP_NAME\n" );
    f_tcl.write("source %s/%s.tcl\n"%(d_json["IP_LOCATION"], d_json["IP_NAME"])); 
    f_tcl.write("run_prj $ADDR_WIDTH $DATA_WIDTH $ID_WIDTH $WR_OUTSTANDING $RD_OUTSTANDING $ECC_EN $IP_LOCATION $PLATFORM_PART $IP_NAME" );
    f_tcl.close();

    result = os.system('./run.csh');
    os.chdir('..');
    return result;

def ip_release(d_json):
    ip_name = d_json["IP_NAME"];
    proj_dir = 'proj_'+ip_name;
    #check IP
    f_stub = proj_dir+r"/"+d_json["IP_NAME"]+"_stub.v";
    f_dcp_in = proj_dir+r"/"+d_json["IP_NAME"]+".dcp";
    if(not os.path.exists(f_stub)):
        raise Exception('Error: Cannot find %s'%f_stub);
    if(not os.path.exists(f_dcp_in)):
        raise Exception('Error: Cannot find %s'%f_dcp_in);

    if(os.path.isdir(ip_name)):
        shutil.rmtree(ip_name);
    os.mkdir(ip_name);
    #stub file
    f_stub_in = open(f_stub, 'r');
    f_stub_out = open(ip_name+r"/"+d_json["IP_NAME"]+"_Stub.v", 'w');
    p_module = r'^module\s+%s'%ip_name;
    p_endmodule = r'^endmodule';
    for line in f_stub_in:
        match_module = re.match(p_module, line);
        match_endmodule = re.match(p_endmodule, line);
        if(match_module):
            l_attr = [];
            l_attr_u2 = [];
            for attr in d_json['ATTRIBUTE'][1]:
                l_attr.append('%s:%s'%(attr, d_json[attr]));
                l_attr_u2.append('%s:<%s>'%(attr, d_json[attr]));
            # (* uv_axi2ddr = "ADDR_WIDTH:<value>, DATA_WIDTH:<value>" *)
            f_stub_out.write('(* %s = "%s" *)\n'%(d_json['ATTRIBUTE'][0], ",".join(l_attr)));
            if("DC_NAME" in d_json.keys()):
                f_stub_out.write('(* UV_HW_IP = "type:<DCMEM>,%s,toSysbus:<uvw_generalHBD>,toFPGA:<%s>" *)\n'%(",".join(l_attr_u2), d_json["DC_NAME"]));
            else:
                f_stub_out.write('(* UV_HW_IP = "type:<DCMEM>,%s,toSysbus:<uvw_generalHBD>,toFPGA:<UV_APCP_DDR4>" *)\n'%(",".join(l_attr_u2)));
        if(match_endmodule):
            if("32g" in ip_name):
                f_stub_out.write(ip32_inline);
            else:
                f_stub_out.write(ip_inline);
        f_stub_out.write(line);
    f_stub_in.close();
    f_stub_out.close();

    #dcp file
    f_dcp_out = ip_name+r"/"+d_json["IP_NAME"]+".dcp";
    shutil.copyfile(f_dcp_in, f_dcp_out);

    #tcl file for uv_shell
    s_enable_paire = [];
    for clk_grp in d_json["CLK_GROUPS"]:
        if("CLOCK_EN" in d_json[clk_grp].keys()):
            if(d_json[clk_grp]["CLOCK_EN"] != "NONE"):
                s_enable_paire.append("{%s %s %s}"%(d_json[clk_grp]["CLOCK"],
                                                    d_json[clk_grp]["CLOCK_EN"],
                                                    d_json[clk_grp]["CLOCK_EN_ACTIVE"])
                                      );
    f_tcl = open(ip_name+r"/"+d_json["IP_NAME"]+".tcl", "w");
    s_tcl = "set_ip -module %s -source_file %s/%s/%s.dcp -clock_enable_pairs {%s} -script_file {prePlace %s/constaint/uvw_axi4_to_ddr4_pblock.tcl}"%(
                ip_name,
                os.getcwd(),
                ip_name,
                ip_name,
                " ".join(s_enable_paire),
                d_json["IP_LOCATION"]
            );
    f_tcl.write(s_tcl);
    f_tcl.close();

    #remove project dir
    shutil.rmtree(proj_dir);

if __name__ == "__main__" :
    usage = 'gen_ddr4_ip.py -j uvw_axi4_to_ddr4.json [--release] [--json_help]';
    parser = OptionParser(usage=usage);
    parser.add_option('-j', '--json', dest='f_json', help='json file to describe IP charactor');
    parser.add_option('--json_help', dest='json_help', action='store_true',
                      help='Information of IP character, and how to configurate the IP via json');
    parser.add_option('--release', dest='ip_release', action='store_true', help='release IP');
    (options, args) = parser.parse_args();

    if(options.f_json == None):
        raise Exception('Error: json file must be provided');

    #load json file
    try:
        f = open(options.f_json, 'r');
        d_json = json.load(f);
    except:
        raise Exception('ERROR: %s has problem! please check it'%options.f_json);

    if(options.json_help):
        for help_info in d_json['HELP']:
            print(help_info);
        sys.exit();
    if(options.ip_release):
        result = 0;
    else:
        result = gen_dcp(d_json);
    if(result == 0):
        ip_release(d_json);
    else:
        print("IP %s generation failed"%d_json["IP_NAME"]);
        print("Follow below steps to accomplish the generation");
        print("1. cd proj_%s"%d_json["IP_NAME"]);
        print("2. ./run.csh");
        print("3. cd ..");
        print("4. gen_ddr4_ip.py -j %s.json --release"%d_json["IP_NAME"]);
