## ------------------------------------------------------------
## Finite-population stochastic individual-based imitation model
## R translation of the original C code
## ------------------------------------------------------------

set.seed(1)

## Parameters
L <- 51L # Number of discrete opinion classes
TL <- 0.02 # Grid scaling used in the C code
N_INDIV <- 10L # Population size

a <- 1.0 # Benefit parameter
c_par <- 1.0 # Social-cost parameter
w <- 0.01 # Assimilation-bias parameter
x_max <- 5.0 # Maximum opinion / usage level

mutation_rate <- 1e-6
selection_scale <- 0.01

n_output <- 100L # Number of recorded time points
n_updates <- 1000000L # Imitation updates per recorded point

## Opinion classes: C indices 0,...,50 correspond to R indices 1,...,51
usage <- x_max * TL * (0:(L - 1L))

## Model functions
assimilation_bias <- exp(-w * usage)
private_benefit <- exp(a * usage)

## ------------------------------------------------------------
## Local mutation between adjacent opinion classes
## ------------------------------------------------------------

mutate_population <- function(opinions, mutation_rate, L) {

## In R, opinion classes are indexed from 1 to L.
## Class 1 corresponds to x = 0.
## Class L corresponds to x = x_max.

mutation_occurs <- runif(length(opinions)) < mutation_rate
mutation_targets <- which(mutation_occurs)

if (length(mutation_targets) == 0L) {
return(opinions)
}

for (individual in mutation_targets) {

position <- opinions[individual]

if (position == 1L) {

## At the lower boundary, mutation can only move upward
opinions[individual] <- 2L

} else if (position == L) {

## At the upper boundary, mutation can only move downward
opinions[individual] <- L - 1L

} else {

## At an interior class, mutation moves to either neighbor
## with equal probability
if (runif(1L) < 0.5) {
opinions[individual] <- position + 1L
} else {
opinions[individual] <- position - 1L
}
}
}

opinions
}

## ------------------------------------------------------------
## Run one simulation
## ------------------------------------------------------------

run_simulation <- function(
N = N_INDIV,
n_output = 100L,
n_updates = 1000000L,
initial_class = 1L,
mutation_rate = 1e-6,
selection_scale = 0.01,
progress = TRUE
) {

## Initially homogeneous population
opinions <- rep(initial_class, N)

## Rows: recorded time points
## Columns: opinion classes
trajectory <- matrix(
0L,
nrow = n_output + 1L,
ncol = L
)

## Record initial state
trajectory[1L, ] <- tabulate(opinions, nbins = L)

for (time_index in seq_len(n_output)) {

for (update_index in seq_len(n_updates)) {

## Population size in each opinion class
location <- tabulate(opinions, nbins = L)

## Mean population usage
total_use <- sum(location * usage) / N

## Shared social cost
social_cost <- c_par * total_use^2

## Discount factor associated with social cost
exp_social_cost <- exp(-social_cost)

## Mean net benefit
mean_benefit <- sum(
private_benefit * exp_social_cost * location
) / N

## Mean assimilation bias
mean_bias <- sum(
assimilation_bias * location
) / N

## Fitness assigned to each opinion class
class_fitness <-
private_benefit * exp_social_cost -
mean_benefit +
social_cost * (assimilation_bias - mean_bias)

## Randomly select focal and model individuals
focal <- sample.int(N, 1L)
model <- sample.int(N, 1L)

if (focal != model) {

focal_class <- opinions[focal]
model_class <- opinions[model]

fitness_difference <-
class_fitness[model_class] -
class_fitness[focal_class]

if (fitness_difference > 0) {

imitation_probability <-
min(1, selection_scale * fitness_difference)

if (runif(1L) < imitation_probability) {
opinions[focal] <- model_class
}
}
}

## After each imitation update, every individual independently
## undergoes local mutation with probability mutation_rate
opinions <- mutate_population(
opinions = opinions,
mutation_rate = mutation_rate,
L = L
)
}

## Record class counts
trajectory[time_index + 1L, ] <-
tabulate(opinions, nbins = L)

if (progress) {
message(
"Recorded time point ",
time_index,
" / ",
n_output
)
}
}

colnames(trajectory) <- sprintf("%.1f", usage)
rownames(trajectory) <- 0:n_output

list(
trajectory = trajectory,
final_opinions = opinions,
usage = usage,
parameters = list(
population_size = N,
n_opinion_classes = L,
x_max = x_max,
mutation_rate = mutation_rate,
selection_scale = selection_scale,
updates_per_record = n_updates
)
)
}

## ------------------------------------------------------------
## Execute
## ------------------------------------------------------------

result <- run_simulation(
N = 10L,
n_output = 100L,
n_updates = 1000000L,
initial_class = 1L, # Class 1 corresponds to x = 0
mutation_rate = 1e-6,
selection_scale = 0.01
)

trajectory <- result$trajectory


## Gray levels: white = 0 individuals, black = 10 individuals
gray_palette <- gray.colors(
n = N_INDIV + 1L,
start = 1,
end = 0
)

image(
x = opinion_axis,
y = time_axis,
z = t(trajectory),
col = gray_palette,
breaks = seq(-0.5, N_INDIV + 0.5, by = 1),
xlab = expression(x),
ylab = "Time",
useRaster = TRUE
)

box()


