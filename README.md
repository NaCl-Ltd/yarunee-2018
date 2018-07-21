# nanobot

## Prerequisites

- ruby

## Setup

- bundle install
- Place official files like this:
  - README.md
  - exe/
  - files/
    - dfltTracesL/
    - problemsL/
    - dfltTracesL.zip
    - problemsL.zip

## Usage

- ./exe/nanobot help

## Run test

- rspec

## Source file

モデルを表すテキスト形式の Source file について
* 空行で区切られたR個の層からなる
* 1 が Full, 0 が Void
* ファイル先頭の層ほど y が大きい
* 各層は
  * ファイル先頭ほど z が大きい
  * 行末ほど x が大きい

```
[x0, yR, zR][x1, yR, zR],...,[xR-1, yR, zR]
[x0, yR, zR-1][x1, yR, zR-1],...,[xR-1, yR, zR-1]
...
[x0, yR, z0][x1, yR, z0],...,[xR-1, yR, z0]

[x0, yR-1, zR][x1, yR-1, zR],...,[xR-1, yR-1, zR]
[x0, yR-1, zR-1][x1, yR-1, zR-1],...,[xR-1, yR-1, zR-1]
...
[x0, yR-1, z0][x1, yR-1, z0],...,[xR-1, yR-1, z0]

...

[x0, y0, zR][x1, y0, zR],...,[xR-1, y0, zR]
[x0, y0, zR-1][x1, y0, zR-1],...,[xR-1, y0, zR-1]
...
[x0, y0, z0][x1, y0, z0],...,[xR-1, y0, z0]
```
