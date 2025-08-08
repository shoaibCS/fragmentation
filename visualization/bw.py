#!/usr/bin/env python3
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import sys
import math

# Constants
QUEUE_DEPTHS = [1, 4, 16, 1024]
COLUMNS_PER_ROW = 3
#LEGEND_LABELS = ['sequential wb - no fragmenation','sequential wb - aggressive fragmentation','parallel wb - aggressive fragmentaion']  # Used in order of files
LEGEND_LABELS = ['XFS 4k BW','XFS 32k BW',"4k no frag"]
def parse_block_size(s):
    s = s.strip().lower()
    if s.endswith('k'):
        return float(s[:-1])
    if s.endswith('m'):
        return float(s[:-1]) * 1024
    return float(s)

def load_and_filter(path, qd):
    df = pd.read_csv(path, sep=r"\s+", header=None)
    if qd not in df[1].unique():
        print(f"Warning: QD={qd} not in {path!r} (found {sorted(df[1].unique())})", file=sys.stderr)
    df = df[df[1] == qd].copy()
    df['bs_label'] = df[0].astype(str)
    df['bs_kb'] = df['bs_label'].apply(parse_block_size)
    return df.sort_values('bs_kb')

def main():
    parser = argparse.ArgumentParser(description="Plot bandwidth vs block-size for 2 or 3 files")
    parser.add_argument('--bandwidth-col', '-b', type=int, default=3,
                        help="zero-based column index of bandwidth metric (default: 3)")
    parser.add_argument('--output-prefix', '-o', default=None,
                        help="output filename prefix (no extension). If omitted, plots show on screen")
    parser.add_argument('file1', help="first input data file")
    parser.add_argument('file2', help="second input data file")
    parser.add_argument('file3', nargs='?', default=None, help="optional third input data file")
    args = parser.parse_args()

    files = [args.file1, args.file2]
    if args.file3:
        files.append(args.file3)

    colors = ['C0', 'C1','hotpink']
    markers = ['o', 's', '^']
    labels = LEGEND_LABELS[:len(files)]

    n = len(QUEUE_DEPTHS)
    cols = COLUMNS_PER_ROW
    rows = math.ceil(n / cols)
    fig, axes = plt.subplots(rows, cols, figsize=(5 * cols, 4 * rows))
    axes = axes.flatten()

    for idx, qd in enumerate(QUEUE_DEPTHS):
        ax = axes[idx]
        dfs = [load_and_filter(f, qd) for f in files]

        all_labels = set()
        for df in dfs:
            all_labels.update(df['bs_label'])
        categories = sorted(all_labels, key=parse_block_size)
        x_pos = list(range(len(categories)))
        cat_to_x = {cat: i for i, cat in enumerate(categories)}

        for i, df in enumerate(dfs):
            xs = [cat_to_x[l] for l in df['bs_label']]
            ax.plot(xs, df[args.bandwidth_col], marker=markers[i], label=labels[i], color=colors[i])

        ax.set_xticks(x_pos)
        ax.set_xticklabels(categories)
        ax.set_xlabel('fio block size')
        ax.set_ylim(0, 5000) 
#        ax.set_ylim(0, 1500000) 
#        ax.set_ylim(0,10000)


        ax.set_title(f'QD = {qd}')
        ax.grid(linestyle='--', alpha=0.5)
        if idx % cols == 0:
       #     ax.set_ylabel('Number of times fragmentation index was positive')
            ax.set_ylabel('Bandwidth (MB/s)')


    for j in range(n, rows * cols):
        fig.delaxes(axes[j])

    axes[n - 1].legend(loc='best')
    plt.suptitle('Bandwidth vs fio block size', y=1.02)
    plt.tight_layout()

    if args.output_prefix:
        base = "./" + args.output_prefix.rstrip('.')
        fig.savefig(base + '.png', bbox_inches='tight')
   #     fig.savefig(base + '.pdf', bbox_inches='tight')
        print(f"Saved plots to {base}.png and {base}.pdf")
    else:
        plt.show()

if __name__ == '__main__':
    main()

