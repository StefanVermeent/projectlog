imgurl <- system.file("figures/projectlog_logo.png", package="projectlog")

sticker(imgurl, package="", p_size=20, s_x=1, s_y=1.05, s_width=1, h_fill = "white", h_color = "black",
        filename="figures/projectlog.png")

usethis::use_logo(system.file("figures/projectlog.png", package="projectlog"))
