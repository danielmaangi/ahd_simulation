gitcreds::gitcreds_set()
usethis::use_mit_license("Shujaaz Inc")
#usethis::use_readme_md()
#usethis::use_git()
usethis::use_git_ignore("cheat.R")
usethis::use_git_ignore(".env")
usethis::use_git_ignore("test.R")
#usethis::use_github()

# documentation
roxygen2::roxygenize()
#renv::snapshot(packages = "rsconnect")
#renv::record("renv@1.0.7")

# options(renv.config.updates.parallel = FALSE)
# renv::update()
