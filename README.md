# CBE ABET Structural Analysis 2022
This repository holds codes to perform structural analysis of the Chemical and Biomolecular Engineering curriculum of the Smith School. 

### Installing Julia and Pluto
To run the notebooks live, you need [Julia](https://julialang.org) and the [Pluto](https://github.com/fonsp/Pluto.jl) notebook package. 
[Julia](https://julialang.org) and [Pluto](https://github.com/fonsp/Pluto.jl) are open source, free and run on all major operating systems and platforms. To install 
[Julia](https://julialang.org) and [Pluto](https://github.com/fonsp/Pluto.jl) please check out the tutorial for 
[MIT 18.S191/6.S083/22.S092 course from Fall 2020](https://computationalthinking.mit.edu/Fall20/installation/).

1. [Install Julia (we are using v1.7.x, newer versions of Julia should also work)](https://julialang.org/downloads/)
1. [Install Pluto.jl](https://github.com/fonsp/Pluto.jl#installation)
1. Clone this repo:
    ```bash
    git clone https://github.com/varnerlab/ENGRI-1120-Cornell-Varner.git
    ```
1. From the Julia REPL (`julia`), run Pluto (a web browser window will pop-up):
    ```julia
    julia> using Pluto
    julia> Pluto.run()
    ```
    _Or you can simply type the following in a terminal:_
    ```bash
    julia -E "using Pluto; Pluto.run()"
    ```
1. From Pluto, open one of the `.jl` notebook files located in the `CBE-ABET-StructuralAnalysis-2022/notebooks/` directory, and then enjoy!

### Static Analysis Notebooks
You can also access static versions of the analysis notebooks.

* [Connectivity of Courses and Performance Indicators](https://htmlview.glitch.me/?https://github.com/varnerlab/CBE-ABET-StructuralAnalysis-2022/blob/main/html/CCA-PICA-Notebook.jl.html): Notebook computes the Course Connectivity Array (CCA) and the Performance Indicator Connectivity Array (PICA) for the CBE curriculum in the Spring 2021, Fall 2021, and Spring 2022 terms.

* [Gaps and Programs Educational Objectives](https://htmlview.glitch.me/?https://github.com/varnerlab/CBE-ABET-StructuralAnalysis-2022/blob/main/html/PEOs-Notebook.jl.html): Notebook explores gaps in the assessment of the CBE curriculum for the Spring 2021, Fall 2021, and Spring 2022 terms. 
