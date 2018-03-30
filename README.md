#  ModeAnalysisGUI

# Overview
ポリゴンを2次元多様体と見做してモード解析（固有振動解析、固有値・固有関数計算）を行います。特に球面の場合球面調和関数と類似した結果が得られます。

# Description
離散微分幾何学に基づいて各頂点におけるラプラシアン を求めて行列に格納しその固有値・固有ベクトルを計算します。ポリゴンは頂点座標の配列と頂点番号三つ組の配列により設定されます。現状ではこれらの配列を動的に生成します。

# Dependency
微分幾何学や行列計算に関するクラスはC++11で ModeAnalysis.cppに統括されています。ポリゴンの作成やGUI部分はSwift4で、上のModeAnalysis.cppをObjective-C++でラップした後呼び出しています。C++部分にはHeader-onlyライブラリであるEigenを内包しています。

# Setup
GUIを含む全体のビルドはXcodeプロジェクトから行います。C++部分のみをビルドする場合ModeAnalysisGUI/DDG/src/で$make demoを実行します。demoはひし形領域上の典型的な計算結果を求めるプログラムです。

# Usage
appを起動すると表示される画面でPrimitiveTypeを選択します。計算の負荷が小さいものはParallelogramおよびSphereです。選択後Calc.ボタンを押すと求解が始まります。なお図形によっては頂点数が多いため数分かかることがあります。その後固有値番号に対応するIDとして整数値を入力すると計算結果がアニメーションにより表示されます。

# Licence
MITライセンスに準拠します。LICENCE.mdをご覧ください。

# Authors
N-Ishida(vega9)

# References
離散微分幾何学(Discrete Differential Geometry,DDG)の公式の導出等はKeenan Crane氏のDISCRETE DIFFERENTIAL GEOMETRY: AN APPLIED INTRODUCTION (https://www.cs.cmu.edu/~kmcrane/Projects/DDG/paper.pdf)を大いに参考にしています。
