
timeline_plot <- function(pattern = "^MILESTONE") {

  if(!grepl(x = pattern, pattern = "\\^MILESTONE")) {
    pattern = paste0("^MILESTONE|", pattern)
  }

  milestones <- gert::git_log() |>
    dplyr::filter(grepl(x = message, pattern = pattern))

  if(nrow(milestones)==0) {
    cli::cli_abort("No milestone commits found to visualize.")
  }

  milestones <- milestones |>
    # Parse information
    dplyr::select(-c(files, merge)) |>
    dplyr::mutate(message = gsub(x = message, pattern = "MILESTONE\\s", "")) |>
    dplyr::mutate(type = regmatches(x = message, m = regexpr(pattern = "^(_|[a-zA-Z])*", text = message))) |>
    dplyr::mutate(message = gsub(x = message, pattern = "^(_|[a-zA-Z])*\\s", replacement = "")) |>
    dplyr::mutate(
      urls = case_when(
        type == "data_access" ~ paste0(gert::git_remote_list()$url |> gsub(x = _, pattern = "\\.git$", replacement = ""), "/tree/main/project_log/", commit, ".R"),
        TRUE ~ paste0(gert::git_remote_list()$url |> gsub(x = _, pattern = "\\.git$", replacement = ""), "/commit/", commit)
      )
    ) |>
    dplyr::arrange(time) |>
    dplyr::mutate(
      date     = as.Date(time),
      month    = lubridate::month(time, label = T),
      ypos     = purrr::rep_along(1:dplyr::n(), c(-0.5, 0.5, -1, 1, -1.5, 1.5))
    )

  f <- function(p) {
    ply <- plotly::ggplotly(p)

    javascript <- HTML(paste("
                           var myPlot = document.getElementsByClassName('js-plotly-plot')[0];
                           myPlot.on('plotly_click', function(data){
                           var urls = ", toJSON(split(gitlog, milestones$type)), ";
                           window.open(urls[data.points[0].data.name][data.points[0].pointNumber]['urls'],'_blank');
                           });", sep=''))
    prependContent(ply, onStaticRenderComplete(javascript))
  }



  f(
    ggplot(data = milestones, aes(x = time, y = 0, color = milestone, label = message)) +
      geom_hline(yintercept = 0, color = "black", size = 0.3) +
      geom_segment(aes(y = position, yend = 0, xend = time, color = milestone), size = 0.2) +
      geom_point(aes(y=0), size = 1) +
      # scale_x_date(date_breaks = "7 days") +
      geom_point(aes(y = position, color = milestone), size = 2) +
      geom_text(data=month_df, aes(x=month_date_range,y=-0.1,label=month_format),size=3,vjust=0.5, color = "black") +
      theme_classic() +
      #   coord_flip() +
      theme(axis.line.y=element_blank(),
            axis.text.y=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            axis.ticks.y=element_blank(),
            axis.text.x =element_blank(),
            axis.ticks.x =element_blank(),
            axis.line.x =element_blank(),
            legend.position = "bottom"
      )
  )


}



