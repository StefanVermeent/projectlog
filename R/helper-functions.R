shuffle <- function(data, shuffle_vars, long_format, seed = seed) {

  if(is.null(shuffle_vars)) {
    return(data)
  }

  if(long_format) {
    row_nums <- data |> group_by_at(shuffle_vars[[1]]) |> summarise(n = n()) |> dplyr::pull(n)
  } else {
    row_nums <- rep(1, nrow(data))
  }

  set.seed(seed)

  data <- shuffle_vars |>
    map_dfc(function(x){
      data |>
        select(matches(x)) |>
        mutate(rows = rep(1:length(row_nums), row_nums)) |>
        group_split(rows) |>
        sample() |>
        bind_rows() |>
        select(-rows)
    }) |>
    bind_cols(
      data |>
        select(-matches(shuffle_vars))
    ) |>
    select(names(data)) |>
    arrange(across(matches(shuffle_vars[[1]])))

  data
}
