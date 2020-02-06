#######################
# help & search
#######################
help.start()
apropos("lm")
args("glm")
? glm
?? glm
RSiteSearch("glm")

db <- news()
news(grepl("^BUG", Category), db=db)
table(news(Version >= "2.10.1", db=db)$Version)

browseURL("http://www.rseek.org")
browseURL("http://search.r-project.org/views/")
browseURL("http://search.r-project.org/")
browseURL("http://www.r-bloggers.com/")

vignette()
vignette("arulesViz")


#######################
# sqldf
#######################

# sqldf 참고 페이지
browseURL("https://code.google.com/p/sqldf/")

if (!length(grep("sqldf", installed.packages()[, "Package"])))
  install.packages("sqldf")              # sqldf 패키지설치
library(sqldf)
library(help="sqldf")

# iris data frame에서 Sepal.Length가 7 이상인 것 구하는 세 가지 예제 
iris[iris$Sepal.Length>7.0, ]
subset(iris, Sepal.Length>7.0)
sqldf("select * from iris where Sepal_Length>7.0")

# 세 가지 방법의 속도 비교
system.time(for (i in 1:1000) {
  x <- iris[iris$Sepal.Length>7.0, ]})

system.time(for (i in 1:1000) {
  x <- subset(iris, Sepal.Length>7.0)})

system.time(for (i in 1:1000) {
  x <- sqldf("select * from iris where Sepal_Length>7.0")})

# exam은 데이터의 공유가 불가합니다. 양해 바랍니다.
#dim(exam)
#sql <- ""
#sql <- paste(sql, "select x.inspect, (x.measure-y.avgm)/y.stdevm as z_measure")
#sql <- paste(sql, "  from exam as x left join (select a.inspect, avg(a.measure) as avgm, stdev(a.measure) as stdevm from exam a group by a.inspect) as y")
#sql <- paste(sql, "    on x.inspect = y.inspect")

#system.time(tmp <- sqldf(sql))
#head(tmp)

# csv 파일에 sqldf 적용하기
write.csv(iris, "iris.csv", quote = FALSE, row.names = FALSE)
iris2 <- read.csv.sql("iris.csv", 
                      sql = "select * from file where Sepal_Length > 5", eol = "\n")



#######################
# recycleing rule
#######################
(x <- 1)
(y <- 2:5)
x + y

(x <- 1:2)
(y <- 2:5)
x + y

(x <- 1:2)
(y <- 2:4)
x + y

# plot 함수에 많은 recycleing rule이 적용됨
# col, lty, pch 등의 인수들
(x <- rnorm(5))
plot(x, col="red", pch=16)
plot(x, col=1:5, pch=15:19)
plot(x, col=1:2, pch=15:16)


#######################
# vectorization
#######################
1:5 + 6:10

x <- 1:10
even <- logical(length(x))

for (i in x) {
  if (i %% 2 == 0) {
    even[i] <- TRUE
  } else {
    even[i] <- FALSE
  }  
}
even

(even_vectorization <- x %% 2 == 0)

if (x %% 2 == 0) "EVEN" else "ODD"
  
ifelse(x %% 2 == 0, "EVEN", "ODD")


#-------------------------------
# apply function
#-------------------------------
(mat <- matrix(1:12, ncol=4, byrow=T))

apply(mat, 1, sum)
apply(mat, 2, mean)
# 7이 들어있는 열에서 몇번째 행에 위치하는지 검사
(tmp <- apply(mat, 2, FUN=function(x, value) grep(value, x), 7))


colMeans(mat)
rowSums(mat)

# lapply example
(x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE,FALSE,FALSE,TRUE)))
(tmp <- lapply(x, mean))
do.call("cbind", tmp)

# arules 패키지에서 tranasction을 만들 경우에 lapply를 자주 사용
#pc <- by(pn_condition[, "item"], pn_condition[, "user"], 
#         function(x) as.character(x))
#pc <- lapply(pc, c)
#pc <- as(pc, "transactions")

# sapply
# tapply
# mapply


#-------------------------------
# sweep function
#-------------------------------
(med.att <- apply(attitude, 2, median))
sweep(data.matrix(attitude), 2, med.att)

set.seed(1)
(mat <- matrix(sample(12), nrow=3))

# propotion
idx <- 2
total <- apply(mat, idx, sum)
sweep(mat, idx, total, FUN="/")

prop.table(mat, idx)

idx <- 1
total <- apply(mat, idx, sum)
sweep(mat, idx, total, FUN="/")

# 상대도수 테이블을 구하는 함수 
prop.table(mat, idx)


#############################################
# performance tuning
#############################################

#-------------------------------------------
# looping  사용 않기 (for, while, repeat)
# ---> vectorize, apply
#-------------------------------------------

vec <- sample(10000000)
over.thresh <- function(x, threshold)
{
  for (i in 1:length(x))
    if (x[i] < threshold)
      x[i] <- 0
  x
}

system.time(tmp <- over.thresh(vec, 100))

over.thresh2 <- function(x, threshold)
{
  ifelse(x < threshold, 0, x)
}  

system.time(tmp <- over.thresh2(vec, 100))
  

over.thresh3 <- function(x, threshold)
{
  x[x < threshold] <- 0
  x
}  

system.time(tmp <- over.thresh3(vec, 100))

# loop 사용하는 예제
ft <- 0:9

system.time({
val <- NULL
for (a in ft)
  for (b in ft)
    for (d in ft)
      for (e in ft)
        val <- c(val, a*b - d*e )
freq <- table(val)})

# loop를 사용하지 않는 예제
system.time({
val <- outer(ft, ft, "*")
val <- outer(val, val,"-")
freq <- table(val)})

#-------------------------------------------
# dataset을 키우지 않기
#-------------------------------------------

# dataset을 키우는 함수
grow <- function(x, y=10) {
  data <- NULL
  
  for (i in 1:x) {
    data <- rbind(data, i:(i+y-1))
  }
  data
}

# dataset을 키우지 않는 함수 
no.grow <- function(x, y=10) {
  data <- matrix(0, nrow=x, ncol=y)
  
  for (i in 1:x) {
    data[i, ] <- i:(i+9)
  }
  data
}

# 두 함수의 속도 비교
system.time(tmp <- grow(1000, 10))
system.time(tmp <- no.grow(1000, 10))

#-------------------------------------------
# 계산 결과의 재사용
#-------------------------------------------
x <- 1:100000
y <- log(x)
system.time(z <- log(x) + 1)    # 재사용 하지 않는 예

system.time(z <- y + 1)         # 재사용하는 예 


#-------------------------------------------
# 재귀호출 사용 않기 (yes?, no?)
#-------------------------------------------
fib <- function(n) {
  fibiter <- function(a, b, count) {
    if (count == 0) b else Recall(a + b, a, count - 1)
  }
  
  fibiter(1, 0,  n)
}

# 재귀호출의 예
system.time(tmp <- fib(800))

# 재귀호출 않고 loop 이용
fib.loop <- function(n) {
  a <- 1
  b <- 0
  
  while (n > 0) {
    tmp <- a
    a <- a + b
    b < tmp
    n <- n - 1
  }
  b
}  

# 재귀호출 않하는 예
system.time(tmp <- fib.loop(800))


#############################################
# performance tuning
#############################################

#-------------------------------------------
# multicore 사용하기 
#-------------------------------------------

if (!length(grep("foreach", installed.packages()[, "Package"])))
  install.packages("foreach")              # foreach 패키지설치
if (!length(grep("doMC", installed.packages()[, "Package"])))
  install.packages("doMC")              # doMC 패키지설치

library(foreach)
library(doMC)
registerDoMC(cores=2)   # 사용할 core 지정

set.seed(1)
m <- matrix(rnorm(9000000), 3000, 3000)

system.time(result <- foreach(i=1:nrow(m), .combine=rbind) %dopar%
  (m[i,] / mean(m[i,])))
  

result <- matrix(0, ncol=3000, nrow=3000)
system.time(for(i in 1:nrow(m))
  result[i, ] <- (m[i,] / mean(m[i,])))

if (!length(grep("plyr", installed.packages()[, "Package"])))
  install.packages("plyr")              # plyr 패키지설치
library(plyr)
(dfx <- data.frame(
  group = c(rep('A', 8), rep('B', 15), rep('C', 6)),
  sex = sample(c("M", "F"), size = 29, replace = TRUE),
  age = runif(n = 29, min = 18, max = 54)
))

dfx <- rbind(dfx, dfx, dfx, dfx, dfx)

system.time(
ddply(dfx, .(group, sex), summarize, 
      mean = round(mean(age), 2),
      sd = round(sd(age), 2)))

system.time(
ddply(dfx, .(group, sex), summarize, .parallel = TRUE,
      mean = round(mean(age), 2),
      sd = round(sd(age), 2)))



#-------------------------------------------
# Memory 절약  
#-------------------------------------------

# temp는 동일한 이름으로 
gets <- function(n=500000) {
  tmp <- runif(n)
  tmp1 <- 2 * tmp
  tmp2 <- trunc(tmp1)
  mean(tmp2 > 0.05)
}

gets2 <- function(n=500000) {
  tmp <- runif(n)
  tmp <- 2 * tmp
  tmp <- trunc(tmp)
  mean(tmp > 0.05)
}

system.time(gets(100000000))
system.time(gets2(100000000))

# 큰 작업 후에는 garbage collection 하기 
gc()



################################
# tips
################################

#---------------------------------------
# interactive object create & reference
#---------------------------------------

(idx <- 1:5)
(obj.names <- paste("var", idx, sep="."))

for (i in idx) assign(obj.names[i], 1:i)

ls(pat="^var\\.")

var.1
var.2
var.3
var.4
var.5

for (i in idx) print(get(obj.names[i]))


#---------------------------------------
# if~else의 주의사항
#---------------------------------------
is.odd <- function(x) {
  if (x %% 2) TRUE
  else FALSE
}

is.odd(5)
is.odd(50)

x <- 5
if (x %% 2) TRUE
else FALSE


#---------------------------------------
# && || vs & |
#---------------------------------------  
x <- TRUE
y <- TRUE

xs <- c(TRUE, FALSE, TRUE)
ys <- c(FALSE, FALSE, TRUE)

!x
!xs

x & y
x && y
xs & ys
xs && ys

x | y
x || y
xs | ys
xs || ys

xor(x, y)
xor(xs, ys)

any(c(TRUE, FALSE, FALSE))
all(c(TRUE, FALSE, FALSE))
all(c(TRUE, TRUE, TRUE))

# on.exit 함수는 함수가 끝날때 반드시 수행하는 코드 지정함
# 에러가 발생하여 종료할 경우에도 수행되므로 유용하게 활용 가능함
plots <- function(x) {
  op <- par()
  on.exit(par(op))
  
  par(mar=c(5,5,5,5))
  
  plot(x)
}

plots(1:10)
plot(1:10)



################################
# graphics tips
################################

# 좌표에 수자가 아닌 임의의 문자를 출력할 때 사용할 수 있는 예제
tickplot <- function(x, ticks, length.out=10, ...) {  
  xlim <- c(1, length(ticks))
  ylim <- range(x)
  
  at <- seq(xlim[1], xlim[2], length.out=length.out)
  labels <- as.character(ticks[at])
  
  plot(x, xlim=xlim, ylim=ylim, xaxt="n", ...)
  axis(1, at=at, labels=labels)
}

tickplot(rnorm(15), LETTERS[1:15])

#---------------------------------------
# las
#---------------------------------------

(alpha <- paste(LETTERS, collapse=""))
(alpha <- rbind(alpha, alpha, alpha, alpha, alpha))
(alpha <- rbind(alpha, alpha))

# 사용자 정의 연산자
"%s%" <- function(x, y) {
  substr(x, y, 5+y-1)  
}

"1234567890abcdefg" %s% 1
"1234567890abcdefg" %s% 2

lable <- sweep(alpha, 1, 1:10, "%s%")

x <- rnorm(10)

# 좌표 축에서 눈금의 표현을 설정하는 방법
# 눈금의 이름이 길 경우에 적당하게 사용 가능
tickplot(x, lable)
tickplot(x, lable, las=1)
tickplot(x, lable, las=2)
tickplot(x, lable, las=3)

plot(x, las=1)
plot(x, las=2)
plot(x, las=3)



