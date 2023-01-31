printing <- function(numbers_of_levels_to_be_uncovered, numbers_of_levels_identified,
                     counts_to_be_uncovered, counts_identified,
                     points_of_change_to_be_uncovered, points_of_change_identified ) {

  cat("number of levels to be = ")
  cat(numbers_of_levels_to_be_uncovered,"\n")
  cat("number of levels found = ")
  cat(numbers_of_levels_identified,"\n")

  cat("counts to be = ")
  cat(counts_to_be_uncovered,"\n")
  cat("counts found = ")
  cat(counts_identified,"\n")

  cat("points of change to be = ")
  cat(points_of_change_to_be_uncovered,"\n")
  cat("points of change found = ")
  cat(points_of_change_identified,"\n")
}

from_beta_vector <- function(betas) {
  matrix_23_rows <- matrix(betas, nrow=23)
  matrix_with_zeros <- rbind(rep(0,p), matrix_23_rows)

  numbers_of_levels <- unlist(lapply(apply(matrix_with_zeros, 2, unique), length))
  counts            <- unlist(lapply(apply(matrix_with_zeros, 2, rle), function(x) x$lengths))
  points_of_change  <- unlist(apply(matrix_with_zeros, 2, function(x) which(x[-1]!=x[-length(x)])))

  return(list(numbers_of_levels=numbers_of_levels, counts=counts, points_of_change=points_of_change))
}


equality <- function(numbers_of_levels_to_be_uncovered, numbers_of_levels_identified,
                     counts_to_be_uncovered, counts_identified,
                     points_of_change_to_be_uncovered, points_of_change_identified ) {


  #now I think that comparing points of change is not necessary, if equality for counts_identified holds

  if (sum(numbers_of_levels_identified == numbers_of_levels_to_be_uncovered) == length(numbers_of_levels_to_be_uncovered)) {  #  first, assess if numbers of levels found are OK
    if (sum(counts_identified == counts_to_be_uncovered) == length(counts_to_be_uncovered)) {  #  if they are OK, check if counts of individual contributions are OK
      #if they are OK, check individual change-points
      if (length(points_of_change_identified) == length(points_of_change_to_be_uncovered)) {  #  first length
        if (sum(points_of_change_identified == points_of_change_to_be_uncovered) == length(points_of_change_to_be_uncovered)) {#then values
          return(1)
        }
      }
    }
  }
  return(0)

}

submodel <- function(numbers_of_levels_A, numbers_of_levels_B,
                     counts_A, counts_B) {
  # A is a submodel of B
  # i.e. A contains at least one more merging of levels than B. That is, A contains LESS (or equal) levels than B

  if (sum(numbers_of_levels_A <= numbers_of_levels_B) == length(numbers_of_levels_A)) {  #  first, assess if numbers of levels found are OK
    #now inside the while we will check compatibility of counts
    A_ind <- 1
    B_ind <- 1
    A_count_sum <- counts_A[A_ind]
    B_count_sum <- counts_B[B_ind]
    while (A_ind <= length(counts_A)) {
      if (B_count_sum > A_count_sum) {   # incompatibility of counts
        return(0)
      } else if (B_count_sum == A_count_sum) {   #exact compatibility of counts so far
        #moving ahead both indices

        if (A_count_sum == 24) {
          A_count_sum <- 0
          B_count_sum <- 0
        }
        A_ind <- A_ind + 1
        B_ind <- B_ind + 1
        A_count_sum <- A_count_sum + counts_A[A_ind]
        B_count_sum <- B_count_sum + counts_B[B_ind]
      } else {
        #efectively B_count_sum < A_count_sum

        #moving ahead only B index
        B_ind <- B_ind + 1
        B_count_sum <- B_count_sum + counts_B[B_ind]

      }

    }
    return(1)

  }
  return(0)

}

