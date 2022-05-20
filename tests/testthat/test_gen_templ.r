tests_dir <- system.file("tests",package="vpRm")
data_dir <- file.path(tests_dir, "data") 
stilt_dir <- file.path(data_dir, "stilt_test")
list.files(stilt_dir )

test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

matchdomain1 <- file.path(stilt_dir,"by-id","202001310500_-72.1898_42.5331_364","202001310500_-72.1898_42.5331_364_foot.nc")
matchdomain2 <- file.path(stilt_dir,"by-id","202007210500_-72.1898_42.5331_364","202007210500_-72.1898_42.5331_364_foot.nc")
matchdomain3 <- file.path(stilt_dir,"by-id","202010101200_-72.1898_42.5331_364","202010101200_-72.1898_42.5331_364_foot.nc")
matchdomain <- c(matchdomain1,matchdomain2,matchdomain3)



