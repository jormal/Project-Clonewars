import os
import re
import sys
import argparse
import subprocess

WORK_DIR = os.path.abspath (os.getcwd ())

def main ():
  try:
    sys.stderr.write ("> Start\n")
    args = read_arg ()
    options = read_options (args)
    run_translator (args, options)
    sys.stderr.write ("> Done\n")
  except Exception as ex:
    exc_type, exc_value, exc_traceback = sys.exc_info ()
    sys.stderr.write ("> Error: {}\n\n".format (ex))
    traceback.print_tb (exc_traceback, file=sys.stderr)
  return None


def read_arg ():
  parser = argparse.ArgumentParser ()
  parser.add_argument ("-i", "--input", type=str, default="", help="file path of input solidity file in CWD (REQUIRED)")
  parser.add_argument ("-o", "--output", type=str, default="./tmp", help="file path of output IR file in CWD (default: STDERR)")
  parser.add_argument ("-m", "--main", type=str, default="", help="name of main contract (default: bottom contract of file)")
  parser.add_argument ("-S", "--solc", type=str, default="", help="version of solidity compiler (default: pragma setting in solidity file)")
  parser.add_argument ("-v", "--version", type=str, default="latest", help="version of IR translator (default: latest)")
  parser.add_argument ("-O", "--option", action="store_true", default=False, help="flag for input options to IR translator (default: False)")
  args = parser.parse_args ()
  args.input = os.path.join (WORK_DIR, args.input)
  if not (os.path.isfile (args.input)) or not (str (args.input).endswith (".sol")):
    raise Exception ("Wrong solidity file")
  args.output = os.path.join (WORK_DIR, args.output)
  args.solc = get_version (args.input) if args.solc == "" else args.solc
  return args

def get_version (input_file):
  pragma_re = re.compile (r".*pragma solidity (.*);.*")
  ver_re = re.compile (r"[=^]([\d]+\.[\d]+\.[\d]+)")
  with open (input_file, "r") as fp:
    sol = fp.read ()
  ver_mass = pragma_re.findall (sol)
  ver_mass = "=0.5.17" if len (ver_mass) == 0 else ver_mass[0]
  ver = ver_re.findall (ver_mass)
  if len (ver) == 0:
    ver_re = re.compile (r"[=^>]([\d]+\.[\d]+\.[\d]+)")
    ver = ver_re.findall (ver_mass)
    if len (ver) == 0:
      ver = "0.5.17"
    else:
      crack = ver[0].split (".")
      crack[2] = str (int (crack[2]) + 1)
      ver = ".".join (crack)
  else:
    ver = ver[0]
  return ver


def read_options (args):
  options = {
    "rm_index": False
  }
  if args.option == True:
    sys.stderr.write ("> Do you want to remove index of variables? (default: false) [y/N] ")
    rm_index = input ()
    if rm_index == "y": 
      options["rm_index"] = True
    elif rm_index == "N":
      options["rm_index"] = False
    else:
      raise Exception("Wrong Option")
  return options


def run_translator (args, options):
  cmd = ["sudo", "docker", "run", "--rm", "--user", "root"]
  cmd += ["-v", "{}:/home/opam/input".format (os.path.dirname (args.input))]
  cmd += ["-v", "{}:/home/opam/output".format (os.path.dirname (args.output))]
  cmd += ["jormal/ir-translator:{}".format (args.version)]
  cmd += ["-input", "/home/opam/input/{}".format (os.path.basename (args.input))]
  cmd += ["-output", "/home/opam/output/{}".format (os.path.basename (args.output))]
  cmd += ["-main", args.main]
  cmd += ["-solc", args.solc]
  if os.path.basename (args.output) != "tmp":
    func_dir = os.path.basename (args.output).split (".")[0] + "_func"
    os.makedirs (os.path.join (os.path.dirname (args.output), func_dir), exist_ok=True)
    cmd += ["-func", "/home/opam/output/{}/".format (func_dir)]
  if options["rm_index"] == True: cmd += ["-rm_index"]
  proc = subprocess.run (cmd, shell=False, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
  if os.path.basename (args.output) == "tmp":
    with open (args.output, "r") as fp:
      sys.stdout.write (fp.read () + "\n")
    os.remove (args.output)
  return None

if __name__ == "__main__":
  main ()