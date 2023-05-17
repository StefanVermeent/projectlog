

#commits <- git_log() |>
#  rename(commit_hash = commit)

#git_tag_list() |>
#  dplyr::rename(tag_hash = commit) |>
#  mutate(
#    commit_hash = (\(x) purrr::pmap_chr(list(name, ref, tag_hash), .f = function(name, ref, tag_hash) {
#      git_commit_info(tag_hash)$parents
#    }))()
#  ) |>
#  left_join(commits) |>
#  select(tag = name, message, tag_hash, commit_hash, author, time, files
#  )
