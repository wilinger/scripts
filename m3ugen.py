#!/usr/bin/env python
import os, sys

'''
Author: Will Wong
https://github.com/wilinger

This script takes in a root directory as argument and recursively
traverses through the directory tree and creates a m3u/m3u8 playlist
on each directory with all songs added from its respective directory
tree. Playlist file names are generated from its base folder name.
'''


def main(rootdir):
    global ext, suffix

    # Specify file extensions to add to playlist
    ext = [".mp3", ".flac", ".m4a", ".aac", ".wav"]

    # Specify m3u or m3u8 playlist type
    suffix = '.m3u8'

    count = 0 
    for root, _, _ in os.walk(rootdir):
        if song_exists(root):
            gen_m3u_file(root)
            count+=1
    print("{0} playlist(s) created.".format(count))

def song_exists(currentdir):
    # Checks directory tree to ensure a song exists before generating m3u file
    for _, _, files in os.walk(currentdir):
        if any(file.endswith(tuple(ext)) for file in files):
            return True
    return False

def gen_m3u_file(currentdir):
    prefix = os.path.basename(currentdir)
    m3ufile = os.path.join(currentdir, prefix+suffix)
    with open(m3ufile, 'w') as root_file:
        root_file.write("#EXTM3U\n")
        for root, _, files in os.walk(currentdir):
            if any(file.endswith(tuple(ext)) for file in files):
                for file in sorted(files):
                    if file.endswith(tuple(ext)):
                        relDir = os.path.relpath(root, currentdir)
                        if relDir == ".":
                            root_file.write(file + '\n')
                        else:
                            root_file.write(os.path.join(relDir, file) + '\n')
        print("{0} file created.".format(m3ufile))
        root_file.close()

if __name__ == "__main__":
    try:
        rootdir = sys.argv[1]
    except IndexError:
        print("Usage: m3ugen.py <folder>")
        sys.exit(1)
    main(rootdir)            
