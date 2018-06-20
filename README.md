#  ModeAnalysisGUI
<img width="499" alt="torus" src="https://user-images.githubusercontent.com/37180011/38131573-96bed6f0-3442-11e8-9659-5c6c87f30a87.png">

| | |
|---|---|
|![](https://user-images.githubusercontent.com/37180011/41652174-53718d1e-74bd-11e8-95ca-1ec84b843c80.png)|![](https://user-images.githubusercontent.com/37180011/41652244-7c73ebe4-74bd-11e8-8325-a41c1dba11fc.png)|
|![](https://user-images.githubusercontent.com/37180011/41652248-82c1a9aa-74bd-11e8-88c4-4a669174a08d.png)|![](https://user-images.githubusercontent.com/37180011/41652270-88bcc614-74bd-11e8-8228-a32fc4ee3bb4.png)|



# Overview
メッシュを2次元多様体と見做してモード解析（固有振動解析、固有値・固有関数計算）を行います。これにより周波数領域で解析する視点を提供し、一例としてメッシュをローパスフィルター（LPF）に通す操作を実現します。

# Description
グラフラプラシアンあるいは離散微分幾何学的なラプラシアンを各頂点ごとに求めて行列に格納しその固有値・固有ベクトルを計算します。

ラプラシアンの固有ベクトルは図形の大域な構造を反映しており、物理的には固有振動に対応しています。これらはManifold Harmonisと呼ばれ、ユークリッド空間におけるフーリエ級数や球面の場合の球面調和関数のように周波数領域での基底となるものです。従って各頂点の座標を固有ベクトルに射影する操作はフーリエ変換の一般化と捉えることができ、Manifold Harmonic Transform (MHT)と呼ばれる空間領域から空間周波数領域への視点の転換を可能にします。MHTの用途として、空間領域での畳み込み演算が周波数領域での単純な積となることを用いて複雑なメッシュ操作を単純な計算に置き換えることが挙げられます。一例としてメッシュにローパスフィルターを作用させる操作を本プログラム中のSeriesExpansionとして実現しています。

# Dependency
微分幾何学や行列計算に関するクラスはC++11で記述されています。ポリゴンの作成やGUI部分はSwift4で、解析の中心を成すModeAnalysis.cppをObjective-C++でラップした後呼び出しています。C++部分にはHeader-onlyライブラリであるEigen及びSpectraを内包しています。

# Setup
GUIを含む全体のビルドはXcodeプロジェクトから行います。C++部分のみをビルドする場合ModeAnalysisGUI/DDG/src/で$make demoを実行します。demoはひし形領域上の典型的な計算結果を求めるプログラムです。

# Usage
appを起動すると表示される画面でPrimitiveTypeを選択しCalc.ボタンを押すと求解が始まり
ます。その後固有値番号に対応するIDとして0以上100未満の整数値を入力すると計算結果がアニメーションにより表示されます。マウスのドラッグとピンチによって視点操作が可能です。animationのチェックを外すと頂点の変位が止まり固有ベクトルの値が元の図形上に示されます。なおBunnyはanimationに未対応のためチェックを外してください。

Calc.後にポップアップからSeriesExpansionを選択すると級数展開（LPF）を行えます。推奨はBunny及びTorusです。なおこのモードでのIDは足し合わせる固有ベクトルの上限を表しています。

# Licence
MITライセンスに準拠します。LICENCE.mdをご覧ください。

# Author
N-Ishida(vega9)

# References
離散微分幾何学(Discrete Differential Geometry,DDG)の公式の導出等はKeenan Crane氏の[DISCRETE DIFFERENTIAL GEOMETRY: AN APPLIED INTRODUCTION ][1]を大いに参考にしています。

[1]:https://www.cs.cmu.edu/~kmcrane/Projects/DDG/paper.pdf
