#!/usr/bin/env python3
# Regenerate the UVHS DDR4 controller DCP and synthesis stub locally.
#
# The flow is profile-relative: IP_LOCATION in the JSON is resolved against the
# JSON's own directory, Vivado intermediates stay in a disposable build dir,
# and only the DCP plus annotated stub are installed into the output dir.
import argparse
import json
import os
import re
import shutil
import subprocess
import sys

# Frozen UVHS checkpoint contract. The staged design binds a 256-bit AXI,
# ECC-off DDR controller; reject configs that would silently diverge.
EXPECTED = {
    "IP_NAME": "uvw_axi4_to_ddr4",
    "PLATFORM_PART": "xcvu19p-fsva3824-2-e",
    "DATA_WIDTH": "256",
    "ADDR_WIDTH": "34",
    "ID_WIDTH": "14",
    "DDR_ECC_EN": "0",
}

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


def validate_profile(d_json):
    for key, value in EXPECTED.items():
        actual = str(d_json.get(key))
        if actual != value:
            raise RuntimeError("%s must be %s for the frozen UVHS DDR contract, got %s"
                               % (key, value, actual))


def write_run_tcl(d_json, ip_location, run_tcl):
    with open(run_tcl, "w") as f_tcl:
        for conf_field in d_json["CONFIG_FIELD"]:
            f_tcl.write("set %s %s\n" % (conf_field, d_json[conf_field]))
        f_tcl.write("set IP_NAME {%s}\n" % d_json["IP_NAME"])
        f_tcl.write("set IP_LOCATION {%s}\n" % ip_location)
        f_tcl.write("set PLATFORM_PART {%s}\n" % d_json["PLATFORM_PART"])
        f_tcl.write("source {%s}\n" % os.path.join(ip_location, d_json["IP_NAME"] + ".tcl"))


def install_stub(d_json, raw_stub, output_stub):
    ip_name = d_json["IP_NAME"]
    module_pattern = r"^module\s+%s" % ip_name
    with open(raw_stub, "r") as f_stub_in, open(output_stub, "w") as f_stub_out:
        for line in f_stub_in:
            if re.match(module_pattern, line):
                attrs = ["%s:%s" % (attr, d_json[attr]) for attr in d_json["ATTRIBUTE"][1]]
                uv_attrs = ["%s:<%s>" % (attr, d_json[attr]) for attr in d_json["ATTRIBUTE"][1]]
                f_stub_out.write('(* %s = "%s" *)\n' % (d_json["ATTRIBUTE"][0], ",".join(attrs)))
                f_stub_out.write('(* UV_HW_IP = "type:<DCMEM>,%s,toSysbus:<uvw_generalHBD>,toFPGA:<%s>" *)\n'
                                 % (",".join(uv_attrs), d_json["DC_NAME"]))
            if re.match(r"^endmodule", line):
                if "32g" in ip_name:
                    f_stub_out.write(ip32_inline)
                else:
                    f_stub_out.write(ip_inline)
            f_stub_out.write(line)


def generate(d_json, json_dir, build_dir, out_dir, force):
    validate_profile(d_json)
    ip_location = os.path.abspath(os.path.join(json_dir, d_json["IP_LOCATION"]))
    if not os.path.isfile(os.path.join(ip_location, d_json["IP_NAME"] + ".tcl")):
        raise RuntimeError("missing generator Tcl under %s" % ip_location)

    ip_name = d_json["IP_NAME"]
    project_dir = os.path.join(build_dir, "proj_" + ip_name)
    if os.path.exists(project_dir):
        if not force:
            raise RuntimeError("build dir exists: %s (pass --force to replace it)" % project_dir)
        shutil.rmtree(project_dir)
    os.makedirs(project_dir)
    os.makedirs(out_dir, exist_ok=True)

    write_run_tcl(d_json, ip_location, os.path.join(project_dir, "run.tcl"))
    # The generator Tcl writes outputs to $env(PWD); pin it to the build dir.
    env = dict(os.environ, PWD=project_dir)
    result = subprocess.run(["vivado", "-mode", "batch", "-source", "run.tcl"],
                            cwd=project_dir, env=env)
    if result.returncode != 0:
        raise RuntimeError("Vivado DDR generation failed; see %s/vivado.log" % project_dir)

    raw_dcp = os.path.join(project_dir, ip_name + ".dcp")
    raw_stub = os.path.join(project_dir, ip_name + "_stub.v")
    for artifact in (raw_dcp, raw_stub):
        if not os.path.isfile(artifact):
            raise RuntimeError("Vivado did not produce %s" % artifact)

    shutil.copyfile(raw_dcp, os.path.join(out_dir, ip_name + ".dcp"))
    install_stub(d_json, raw_stub, os.path.join(out_dir, ip_name + "_Stub.v"))
    print("INFO: installed %s.dcp and %s_Stub.v in %s"
          % (ip_name, ip_name, os.path.abspath(out_dir)))


def main():
    parser = argparse.ArgumentParser(description="Generate the UVHS DDR4 DCP and stub")
    parser.add_argument("-j", "--json", required=True,
                        help="JSON file describing the IP configuration")
    parser.add_argument("--build-dir", default=None,
                        help="disposable Vivado build dir (default: <json_dir>/.build)")
    parser.add_argument("--out-dir", default=None,
                        help="install dir for the DCP/stub (default: <json_dir>)")
    parser.add_argument("--force", action="store_true",
                        help="replace an existing build dir")
    parser.add_argument("--json-help", action="store_true",
                        help="print the JSON configuration help and exit")
    args = parser.parse_args()

    f_json = os.path.abspath(args.json)
    try:
        with open(f_json, "r") as f:
            d_json = json.load(f)
    except (OSError, ValueError) as exc:
        raise RuntimeError("cannot load %s: %s" % (f_json, exc))

    if args.json_help:
        for help_info in d_json["HELP"]:
            print(help_info)
        return

    json_dir = os.path.dirname(f_json)
    build_dir = os.path.abspath(args.build_dir) if args.build_dir else os.path.join(json_dir, ".build")
    out_dir = os.path.abspath(args.out_dir) if args.out_dir else json_dir
    generate(d_json, json_dir, build_dir, out_dir, args.force)


if __name__ == "__main__":
    sys.exit(main())
