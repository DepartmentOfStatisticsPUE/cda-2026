#' ---
#' title: Categorical data
#' author: Maciej Beręsewicz
#' ---
#' 

using DataFrames

df = DataFrame(group = ["A", "B", "C", "B", "A"]);
df.group_B = Int.(df.group .== "B");
df.group_C = Int.(df.group .== "C");
df


using StatsModels, CategoricalArrays

df.group = categorical(df.group)   # reference: A (alphabetical)


modelmatrix(@formula(0 ~ group), df)


# TBA


# TBA
