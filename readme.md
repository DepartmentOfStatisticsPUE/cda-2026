# Categorical Data Analysis 2025/26

## Outline of lecture

1. Categorical data - [notebook](https://htmlpreview.github.io/?https://github.com/DepartmentOfStatisticsPUE/cda-2026/blob/main/codes/qmd/01-categorical-data.html)
2. Simpson's paradox - [notebook](https://htmlpreview.github.io/?https://github.com/DepartmentOfStatisticsPUE/cda-2026/blob/main/codes/qmd/02-simpson-paradox.html)
3. Contingency tables - [notebook](https://htmlpreview.github.io/?https://github.com/DepartmentOfStatisticsPUE/cda-2026/blob/main/codes/qmd/03-ctables.html)
4. Discrete distributions - [notebook](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/codes/qmd/04-distributions.html)
5. Maximum likelihood estimation - [notebook](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/codes/qmd/05-mle.html)
6. Goodness of fit - [notebook](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/codes/qmd/06-gof.html)


## Extra materials

- Optimization methods for MLE - [notebook](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/codes/qmd/05a-optimization-methods.html)

## Case study

[TBA]

## Code files for download

| # | Topic | R | Python | Julia | Jupyter |
|---|-------|---|--------|-------|---------|
| 1 | Categorical data | [.R](codes/R/01-categorical-data.R) | [.py](codes/python/01-categorical-data.py) | [.jl](codes/julia/01-categorical-data.jl) | [.ipynb](codes/notebooks/01-categorical-data.ipynb) |
| 2 | Simpson's paradox | [.R](codes/R/02-simpson-paradox.R) | -- | -- | -- |
| 3 | Contingency tables | [.R](codes/R/03-ctables.R) | [.py](codes/python/03-ctables.py) | [.jl](codes/julia/03-ctables.jl) | [.ipynb](codes/notebooks/03-ctables.ipynb) |
| 4 | Discrete distributions | [.R](codes/R/04-distributions.R) | [.py](codes/python/04-distributions.py) | [.jl](codes/julia/04-distributions.jl) | [.ipynb](codes/notebooks/04-distributions.ipynb) |
| 5 | Maximum likelihood estimation | [.R](codes/R/05-mle.R) | [.py](codes/python/05-mle.py) | [.jl](codes/julia/05-mle.jl) | [.ipynb](codes/notebooks/05-mle.ipynb) |
| 6 | Goodness of fit | [.R](codes/R/06-gof.R) | [.py](codes/python/06-gof.py) | [.jl](codes/julia/06-gof.jl) | [.ipynb](codes/notebooks/06-gof.ipynb) |

## Problem sets

Submit solutions as a **single HTML file** via **Moodle**.

| # | Topic | HTML | QMD | Jupyter | Deadline |
|---|-------|------|-----|---------|----------|
| 1 | Vacancy analysis (categorical data, distributions, MLE) | [html](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/homeworks/hw01-problem-set.html) | [qmd](homeworks/hw01-problem-set.qmd) | [ipynb](homeworks/hw01-problem-set.ipynb) | 2026-03-31 23:59 |
| 2 | TBA | -- | -- | -- | TBA |
| 3 | TBA | -- | -- | -- | TBA |

## Example final test

Example test -- [qmd](example-test/example-test.qmd), [html](https://htmlpreview.github.io/?https://raw.githubusercontent.com/DepartmentOfStatisticsPUE/cda-2026/refs/heads/main/example-test/example-test.html)

## Required packages / modules

-   R:
    -   `distributions3`,
    -   `maxLik`, `rootSolve`
    - `vcd`, `fitdistrplus`
    - `marginaleffects`, `modelsummary` 
    - `car`
    - `see`, `performance`, `patchwork`
    - `geepack`
-   Python:
    -   `scipy`, `numpy`, `pandas`
    - `pingouin`, `matplotlib`, `statsmodels`
-   Julia:
    -   `Distributions.jl`, `DataFrames.jl`,
    -   `Optim.jl`, `Roots.jl`
    - `HypothesisTests.jl`, `StatsBase.jl`
    - `FreqTables.jl`, `CSV.jl`
    - `Effects.jl`
    - `GLM.jl`


## Description of the data

Source:

+ id -- company identifier
+ woj -- region (województwo) id (02, 04, ..., 32)
+ public -- is the company public (1) or private (0)?
+ size -- size of the company (small = up to 9 employees, medium = 10 to 49, big = over 49)
+ nace -- NACE (PKD) sections (1 letter)
+ nace_division -- NACE (PKD) division (2-digits, https://www.biznes.gov.pl/pl/klasyfikacja-pkd) 
+ vacancies -- how many vacancies the company reported?

Sample rows from the dataset

```r
           id woj public   size nace nace_division vacancies
    1:  27350  14      1  Large    O            84         2
    2:  26705  14      1  Large    O            84         1
    3: 257456  24      1  Large    O            84         2
    4: 183657  16      1 Medium    O            84         0
    5: 200042  18      1 Medium    O            84         0
   ---                                                      
57476: 244800  08      1 Medium    P            85         0
57477:  62309  08      1 Medium    R            93         0
57478: 106708  08      0 Medium    B            08         0
57479:  62264  08      0 Medium    B            08         0
57480: 255865  08      0  Small    C            23         0
```



## Software versions

```r
R version 4.4.2 (2024-10-31)
```

```python
Python 3.12.7 | packaged by Anaconda, Inc. | (main, Oct  4 2024, 08:22:19) [Clang 14.0.6 ]
```

```julia
Julia Version 1.11.3
Commit d63adeda50d (2025-01-21 19:42 UTC)
```