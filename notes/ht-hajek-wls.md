---
title: Horvitz-Thompson, Hajek, and Weighted Least Squares Estimators
date: 2025-12-10
is_notes: true
---

Let $Y_i$ be the outcome of interest for unit $i$, 
$D_i$ be a binary treatment indicator 
($1$ if treated and $0$ if control),
and $X_i$ be a vector of covariates for unit $i$.
Let $e(X_i) = P(D_i = 1 \mid X_i)$ be the propensity score,
the probability of receiving treatment given covariates.
A common strategy to 
estimate the **average treatment effect (ATE)**
under unconfoundedness and overlap assumptions
is to use **inverse probability weighting (IPW)**.
There are three popular estimators based on IPW:

1. **Horvitz-Thompson Estimator**:
    $$
    \hat{\tau}^{\text{ht}} 
    = \frac{1}{N} \sum_{i=1}^N 
    \left( \frac{D_i Y_i}{e(X_i)} - \frac{(1 - D_i) Y_i}{1 - e(X_i)} \right)
    $$
    This estimator weights each observed outcome by the inverse of the probability
    of receiving the treatment actually received.

2. **Hajek Estimator**:
    $$
    \hat{\tau}^{\text{hajek}}
    = \frac{\sum_{i=1}^N \frac{D_i Y_i}{e(X_i)}}{\sum_{i=1}^N \frac{D_i}{e(X_i)}}
    - \frac{\sum_{i=1}^N \frac{(1 - D_i) Y_i}{1 - e(X_i)}}{\sum_{i=1}^N \frac{(1 -
    D_i)}{1 - e(X_i)}}
    $$
    This estimator normalizes the weights so that they sum to one
    within each treatment group.

3. **Weighted Least Squares (WLS) Estimator**:
    Regress $Y_i$ on $(1, D_i)$ using weights $W_i$,
    where the weights are defined as
    $$
    W_i = \frac{D_i}{e(X_i)} + \frac{(1 - D_i)}{1 - e(X_i)}.
    $$
    The coefficient on $D_i$ from this regression,
    denoted as $\hat{\tau}^{\text{wls}}$,
    is the WLS estimator of the ATE.

All three estimators are consistent for the ATE
under the assumptions of unconfoundedness and overlap.
Intrestingly, the Hajek and WLS estimators
are numerically equivalent,
i.e., $\hat{\tau}^{\text{hajek}} = \hat{\tau}^{\text{wls}}$,
as can be shown by the following derivation.

Let's start with the minimization problem for the WLS estimator:
$$
\begin{aligned}
&\mathrel{\phantom{=}} 
\min_{\tau} \sum_{i=1}^N W_i (Y_i - \alpha - D_i \tau)^2 \\
&= \min_{\tau} \sum_{i: D_i=1} W_i (Y_i - \alpha - \tau)^2
+ \sum_{i: D_i=0} W_i (Y_i - \alpha)^2.
\end{aligned}
$$
We can solve for $\hat{\alpha}$ by considering
$$
\min_{\alpha} \sum_{i: D_i=0} W_i (Y_i - \alpha)^2,
$$
which gives us
$$
\hat{\alpha} = \frac{\sum_{i: D_i=0} W_i Y_i}{\sum_{i: D_i=0} W_i}
= \frac{\sum_{i=1}^N \frac{(1 - D_i) Y_i}{1 - e(X_i)}}{\sum_{i=1}^N \frac{(1 -
D_i)}{1 - e(X_i)}}.
$$
Substituting $\hat{\alpha}$ back into the WLS minimization problem,
we have
$$
\min_{\tau} \sum_{i: D_i=1} W_i (Y_i - \hat{\alpha} - \tau)^2.
$$
Taking the derivative with respect to $\tau$ and setting it to zero,
we have
$$
\sum_{i: D_i=1} W_i (Y_i - \hat{\alpha} - \hat{\tau}^{\text{wls}}) = 0,
$$
which leads to
$$
\hat{\tau}^{\text{wls}}
= \frac{\sum_{i: D_i=1} W_i Y_i}{\sum_{i: D_i=1} W_i} - \hat{\alpha} 
= \frac{\sum_{i=1}^N \frac{D_i Y_i}{e(X_i)}}{\sum_{i=1}^N \frac{D_i}{e(X_i)}}
- \frac{\sum_{i=1}^N \frac{(1 - D_i) Y_i}{1 - e(X_i)}}{\sum_{i=1}^N \frac{(1 -
D_i)}{1 - e(X_i)}}
= \hat{\tau}^{\text{hajek}}.
$$
Thus, we have shown that the Hajek estimator
and the WLS estimator are numerically equivalent.



