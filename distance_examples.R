# Distances in R
# some examples after reading ?dist

require(graphics)

x <- matrix(1:25, nrow = 5) # -> 4x4 matrix
x
#
# [,1] [,2] [,3] [,4] [,5]
# [1,]    1    6   11   16   21
# [2,]    2    7   12   17   22
# [3,]    3    8   13   18   23
# [4,]    4    9   14   19   24
# [5,]    5   10   15   20   25


dist(x)
#
#          1        2        3        4
# 2 2.236068                           
# 3 4.472136 2.236068                  
# 4 6.708204 4.472136 2.236068         
# 5 8.944272 6.708204 4.472136 2.236068

dist(x, method = "euclidean", diag = TRUE, upper = TRUE, p = 2)
#          1        2        3        4        5
# 1 0.000000 2.236068 4.472136 6.708204 8.944272
# 2 2.236068 0.000000 2.236068 4.472136 6.708204
# 3 4.472136 2.236068 0.000000 2.236068 4.472136
# 4 6.708204 4.472136 2.236068 0.000000 2.236068
# 5 8.944272 6.708204 4.472136 2.236068 0.000000

dist(x, method = "man")
# 
#  2  3  4
#  5         
# 10  5      
# 15 10  5   
# 20 15 10  5

dist(x, method = "max")
# 
#   1 2 3 4
# 2 1      
# 3 2 1    
# 4 3 2 1  
# 5 4 3 2 1


minkowskiDist <- dist(x, method = "minkowski")
minkowskiDist
# 
#          1        2        3        4
# 2 2.236068                           
# 3 4.472136 2.236068                  
# 4 6.708204 4.472136 2.236068         
# 5 8.944272 6.708204 4.472136 2.236068
attributes(minkowskiDist)
#
# $Size
# [1] 5
# $Diag
# [1] FALSE
# $Upper
# [1] FALSE
# $method
# [1] "minkowski"
# $p
# [1] 2
# $call
# dist(x = x, method = "minkowski")
# $class
# [1] "dist"



