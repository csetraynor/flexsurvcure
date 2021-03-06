##' Mixture cure models
##'
##' Probability density, distribution, quantile, random generation, hazard
##' cumulative hazard, mean, and restricted mean functions for generic
##' mixture cure models.  These distribution functions take as arguments
##' the corresponding functions of the base distribution used.
##'
##' @aliases dmixsurv pmixsurv qmixsurv rmixsurv
##' hmixsurv Hmixsurv mean_mixsurv rmst_mixsurv
##' @param pfun The base distribution's cumulative distribution function.
##' @param dfun The base distribution's probability density function.
##' @param x,q,t Vector of times.
##' @param p Vector of probabilities.
##' @param n Number of random numbers to simulate.
##' @param theta The estimated cure fraction.
##' @param ... additional parameters to be passed to the pdf or cdf of the base
##' distribution.
##' @return \code{dmixsurv} gives the density, \code{pmixsurv} gives the
##' distribution function, \code{hmixsurv} gives the hazard and
##' \code{Hmixsurv} gives the cumulative hazard.
##'
##' \code{qmixsurv} gives the quantile function, which is computed by crude
##' numerical inversion.
##'
##' \code{rmixsurv} generates random survival times by using \code{qmixsurv}
##' on a sample of uniform random numbers.  Due to the numerical root-finding
##' involved in \code{qmixsurv}, it is slow compared to typical random number
##' generation functions.
##'
##' \code{mean_mixsurv} and \code{rmst_mixsurv} give the mean and restricted
##' mean survival times, respectively.
##' @author Jordan Amdahl <jrdnmdhl@gmail.com>
##' @keywords distribution
##' @name mixsurv
NULL

##' @export
##' @rdname mixsurv
pmixsurv = function(pfun, q, theta, ...) {
  dots <- list(...)
  args <- dots
  args$lower.tail <- F
  args$log.p <- F
  out <- theta + (1 - theta) * do.call(pfun, append(list(q), args))
  if (is.null(dots$lower.tail) || dots$lower.tail) {
    out <- 1 - out
  }
  if (!is.null(dots$log.p) && dots$log.p) {
    out <- log(out)
  }
  return(out)
}

##' @export
##' @rdname mixsurv
hmixsurv = function(dfun, pfun, x, theta, ...) {
  dots <- list(...)
  pargs <- dots
  pargs$lower.tail <- F
  pargs$log.p <- F
  pargs$log <- NULL
  dargs <- dots
  dargs$log <- F
  u_surv <- do.call(pfun, append(list(x), pargs))
  u_pdf <- do.call(dfun, append(list(x), dargs))
  out <- ((1 - theta) * u_pdf) / (theta + (1 - theta) * u_surv)
  if (!is.null(dots$log) && dots$log) {
    out <- log(out)
  }
  return(out)
}

##' @export
##' @rdname mixsurv
Hmixsurv = function(pfun, x, theta, ...) {
  dots <- list(...)
  pargs <- dots
  pargs$lower.tail <- F
  pargs$log.p <- F
  pargs$log <- NULL
  surv <- do.call(pmixsurv, append(list(pfun, x, theta), pargs))
  out <- -log(surv)
  if (!is.null(dots$log) && dots$log) {
    out <- log(out)
  }
  return(out)
}

##' @export
##' @rdname mixsurv
dmixsurv = function(dfun, pfun, x, theta, ...) {
  dots <- list(...)
  pargs <- dots
  pargs$lower.tail <- F
  pargs$log.p <- F
  pargs$log <- NULL
  hargs <- dots
  hargs$log <- F
  u_surv <- do.call(pmixsurv, append(list(pfun, x, theta), pargs))
  u_haz <- do.call(hmixsurv, append(list(dfun, pfun, x, theta), hargs))
  out <- u_surv * u_haz
  if (!is.null(dots$log) && dots$log) {
    out <- log(out)
  }
  return(out)
}

##' @export
##' @rdname mixsurv
qmixsurv = function(pfun, p, theta, ...) {
  dots <- list(...)
  args <- dots
  args$lower.tail <- F
  args$log.p <- F
  if (dots$log.p) p <- exp(p)
  if (!dots$lower.tail) p <- 1 - p
  out <- do.call(
    qgeneric,
    append(
      list(
        function(...) pmixsurv(pfun, ...),
        p = p,
        theta = theta
      ),
      args
    )
  )
  return(out)
}


##' @export
##' @rdname mixsurv
rmixsurv = function(pfun, n, theta, ...) {
  dots <- list(...)
  args <- dots
  args$lower.tail <- F
  args$log.p <- F
  if (dots$log.p) p <- exp(p)
  if (!dots$lower.tail) p <- 1 - p
  out <- do.call(
    qgeneric,
    append(
      list(
        function(...) pmixsurv(pfun, ...),
        p = runif(n),
        theta = theta
      ),
      args
    )
  )
  return(out)
}

##' @export
##' @rdname mixsurv
rmst_mixsurv = function(pfun, t, theta, ...) {
  args <- list(...)
  out <- do.call(
    rmst_generic,
    append(
      list(
        function(q, ...) pmixsurv(pfun, q, ...),
        t = t,
        theta=theta
      ),
      args
    )
  )
  return(out)
}

##' @export
##' @rdname mixsurv
mean_mixsurv = function(pfun, theta, ...) {
  if(theta > 0) {
    out <- Inf
  }else {
    args <- list(...)
    out <- do.call(
      rmst_generic,
      append(
        list(
          pfun,
          t = Inf,
          start = 0
        ),
        args
      )
    )
  }
  return(out)
}

