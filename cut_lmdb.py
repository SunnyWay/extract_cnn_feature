import lmdb
import sys

def usage():
    print "cut_lmdb.py lmdb_dir num"
    print ""
    print "cut the lmdb, remain the first [num] entries."
    print ""
    print "lmdb_dir:\twhere the lmdb is"
    print "num:\thow many entries will be remain"

def cut(lmdb_dir, num):
    env = lmdb.open(lmdb_dir, map_size=int(1e12))
    with env.begin(write=True, buffers=True) as txn:
        with txn.cursor() as cur:
            cur.set_key('{:0>10d}'.format(num))
            while cur.delete():
                pass

if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()
        sys.exit(2)

    lmdb_dir = sys.argv[1]
    num = int(sys.argv[2])

    cut(lmdb_dir, num)
