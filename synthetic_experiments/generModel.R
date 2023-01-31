##### Model matrix (data.frame) generation
generModel = function(n, p, rho){
  ## generation iid W[i,] ~ N(0,S), S=(1-a)*I_p + a*11'
  W <- matrix(rnorm(n*p),n,p)
  a <- 2*sin(pi/6*rho)
  b1 <- sqrt(1-a); b2 <- (sqrt(a*p+1-a)-b1)/p
  W <- t(apply(W,1,function(w) w <- b1*w+b2*sum(w) ) )
  #check:
  #U <- apply(W, 2, function(x) pnorm(x) ); print(round(100*cor(U)))
  XX <- lapply(data.frame(W), function(x) as.factor(ceiling(24*pnorm(x))) )
  as.data.frame(XX)
}
