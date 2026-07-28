# Builds the test hubs the benchmark measures against.
#
# The starting point is a real hub config that a user (ruarai) shared on #295,
# because validating their submissions was slow:
# https://github.com/hubverse-org/hubValidations/issues/295#issuecomment-5029770516
#
# `acefa-tasks.json` is their config, unchanged. Two things about it make
# validation expensive. Every task ID value is optional, and `origin_date` lists
# all 365 days of the year, because it records the last day of reliable data and
# that differs by location and disease.
#
# Multiply those value lists together and a single round has about 3.9 million valid
# value combinations grid rows. Validation currently builds that whole valid value
# grid and matches the submission against it. Their submission is 13 million rows,
# but it only uses 25 of the 10,950 date/location/disease combinations the config
# allows.
#
# So the submission is a small, uneven corner of a very large space of
# possibilities. That gap is what the new grid-free approach takes advantage of,
# which means a test hub that lost the gap would make the new code look better
# than it is. The size list below says which sizes keep it and which change one
# side on purpose.
#
# Sourced by run-benchmark.R; also usable on its own:
#   Rscript -e 'source("_benchmark/make-hub.R"); make_benchmark_hub("S")'

# Size definitions ------------------------------------------------------------

# Each size is a size. The `cfg_*` entries set how many values the config allows,
# which decides how big the valid value grid becomes. The rest set how much
# data is actually submitted.
#
# The L size is ruarai's config exactly, which assert_faithful_to_acefa() checks.
# Every other size is the same shape, scaled up or down.
#
# Submitted rows = units * samples * (2 * horizons used + 2), from
# make_unit_rows().
#
# There are three groups, because the current code and its planned replacement can
# get slow for different reasons, and a size that changed two things at once could
# not tell us which was to blame.
#
# - S, M and L grow the config and the submission together, like a real hub.
# - G1 to G3 grow only the config, so any extra memory has to be the valid value
#   grid. This is where today's cost sits: memory grows in step with that grid.
# - the `mt<N>` variants add model tasks while the config and the submission stay
#   the same size. This is where the replacement could get slow instead. The plan
#   is to test rows against one model task at a time; if it kept a separate
#   true/false marker per row for every model task, memory would grow with rows
#   times model tasks. #356 says not to do that, and this is how we would notice.
#   It needs a size with a lot of data to show up.
BENCHMARK_SIZES <- list(
  S = list(
    cfg_round_id = 4,
    cfg_origin_date = 28,
    cfg_horizon = 15,
    cfg_location = 4,
    data_origin_date = 3,
    units = 4,
    samples = 250
  ),
  M = list(
    cfg_round_id = 13,
    cfg_origin_date = 91,
    cfg_horizon = 29,
    cfg_location = 6,
    data_origin_date = 4,
    units = 10,
    samples = 1000
  ),
  L = list(
    cfg_round_id = 52,
    cfg_origin_date = 365,
    cfg_horizon = 71,
    cfg_location = 10,
    data_origin_date = 6,
    units = 25,
    samples = 4000
  ),
  # Only the config grows in these; the submission stays at about 65k rows. The
  # size where building the valid value grid runs out of memory is the ceiling.
  G1 = list(
    cfg_round_id = 52,
    cfg_origin_date = 365,
    cfg_horizon = 71,
    cfg_location = 30,
    data_origin_date = 3,
    units = 2,
    samples = 250
  ),
  G2 = list(
    cfg_round_id = 52,
    cfg_origin_date = 365,
    cfg_horizon = 71,
    cfg_location = 100,
    data_origin_date = 3,
    units = 2,
    samples = 250
  ),
  G3 = list(
    cfg_round_id = 104,
    cfg_origin_date = 730,
    # Kept at L's value on purpose. make_unit_rows() works out the submitted rows
    # from the horizon list, so a longer list here would grow the submission too,
    # and then we could not tell the two apart, which is the whole point of these
    # sizes.
    cfg_horizon = 71,
    cfg_location = 100,
    data_origin_date = 3,
    units = 2,
    samples = 250
  )
)

# Each list of allowed values is rebuilt from a rule rather than trimmed out of
# the file, so a size can be bigger than ruarai's hub as well as smaller. At the L
# size every rule has to give back exactly their values.
cfg_round_ids <- function(n) {
  as.character(as.Date("2026-01-08") + seq(0, by = 7, length.out = n))
}
cfg_origin_dates <- function(n) {
  as.character(as.Date("2026-01-01") + seq_len(n) - 1L)
}
cfg_horizons <- function(n) as.integer(seq(-14L, length.out = n))
cfg_locations <- function(n) {
  acefa <- c("AUS", "NZ", "ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA")
  if (n <= length(acefa)) {
    return(acefa[seq_len(n)])
  }
  c(acefa, sprintf("X%02d", seq_len(n - length(acefa))))
}

# Config ----------------------------------------------------------------------

# simplifyVector = FALSE reads the config as plain nested lists. That way writing
# it back out produces the same JSON shape we read in: single values stay single
# values, and lists stay lists.
read_acefa_config <- function(benchmark_dir) {
  jsonlite::read_json(
    file.path(benchmark_dir, "acefa-tasks.json"),
    simplifyVector = FALSE
  )
}

tier_config <- function(acefa, size_spec, variant = list(n_model_tasks = 1L)) {
  config <- acefa
  mt <- config$rounds[[1]]$model_tasks[[1]]

  # target and pathogen are the same in every size. There are only 5 targets (one
  # of which is never submitted) and 3 diseases, and holding them still means each
  # sample covers the same rows whatever the size.
  scaled <- list(
    round_id = cfg_round_ids(size_spec$cfg_round_id),
    origin_date = cfg_origin_dates(size_spec$cfg_origin_date),
    horizon = cfg_horizons(size_spec$cfg_horizon),
    location = cfg_locations(size_spec$cfg_location)
  )
  for (task_id in names(scaled)) {
    mt$task_ids[[task_id]]$optional <- as.list(scaled[[task_id]])
  }

  # ruarai's config asks for at least 1000 samples, which the small sizes do not
  # have. Scaling both limits with the size keeps the same 1-to-4 ratio, so the
  # checks on sample counts still do their work instead of simply failing.
  params <- mt$output_type$sample$output_type_id_params
  params$max_samples_per_task <- as.integer(size_spec$samples)
  params$min_samples_per_task <- max(1L, as.integer(size_spec$samples) %/% 4L)
  mt$output_type$sample$output_type_id_params <- params

  config$rounds[[1]]$model_tasks[[1]] <- mt
  if (variant$n_model_tasks > 1L) {
    config$rounds[[1]]$model_tasks <- split_model_tasks(
      mt,
      variant$n_model_tasks
    )
  }
  config
}

# ruarai's hub has one model task, so on its own it cannot exercise the #355 work
# of deciding which model task each row belongs to: with one model task there is no
# decision to make.
#
# This splits it into N. The locations are shared out between N - 1 model tasks,
# each covering all the diseases but one, and the last model task takes the
# remaining disease across every location. Two things about that arrangement
# matter:
#
# - **No single column is enough to tell the model tasks apart.** Disease cannot
#   separate the location groups from each other, and location cannot separate any
#   of those groups from the last model task. You need both together. So the new
#   code has to look for a combination of columns rather than getting away with
#   one, and this is a shape real hubs have, where different places report on
#   different diseases.
# - **No row can belong to two model tasks.** The location groups do not overlap
#   each other, and each uses a different disease from the last model task.
#
# N is an argument rather than a fixed 3, so the cost of sorting rows into model
# tasks can be measured against how many of them there are. The groups share out
# one set of values between them, so the total number of valid value grid rows stays the
# same as N grows. That is deliberate: it separates the cost of having more model
# tasks from the cost of a bigger config.
#
# Whichever columns are used to split, they have to hold the same value throughout
# a submission unit (one origin_date, location and disease). Splitting by target
# looks just as reasonable in the config but is not: within a unit the same sample
# ids are used for every target, so splitting by target would put one sample id in
# two model tasks, and check_tbl_spl_mt_unique rejects that.
split_model_tasks <- function(mt, n_model_tasks) {
  pathogens <- unlist(mt$task_ids$pathogen$optional)
  locations <- unlist(mt$task_ids$location$optional)
  n_groups <- n_model_tasks - 1L
  if (length(pathogens) < 2L) {
    stop(
      "The mt variants need at least 2 pathogens to split on.",
      call. = FALSE
    )
  }
  if (n_groups < 2L || n_groups > length(locations)) {
    stop(
      "mt",
      n_model_tasks,
      " needs between 3 and ",
      length(locations) + 1L,
      " modeling tasks for this size's ",
      length(locations),
      " locations.",
      call. = FALSE
    )
  }

  groups <- split(
    locations,
    cut(seq_along(locations), n_groups, labels = FALSE)
  )
  splits <- c(
    lapply(groups, function(group) {
      list(pathogen = utils::head(pathogens, -1L), location = group)
    }),
    list(list(pathogen = utils::tail(pathogens, 1L), location = locations))
  )
  lapply(unname(splits), function(split) {
    out <- mt
    out$task_ids$pathogen$optional <- as.list(split$pathogen)
    out$task_ids$location$optional <- as.list(split$location)
    out
  })
}

# Variants are "acefa" (the config as contributed, one modeling task) or "mt<N>"
# for an N-modeling-task split, e.g. "mt3" or "mt10".
parse_variant <- function(variant) {
  if (identical(variant, "acefa")) {
    return(list(name = variant, n_model_tasks = 1L))
  }
  n <- suppressWarnings(as.integer(sub("^mt", "", variant)))
  if (!grepl("^mt[0-9]+$", variant) || is.na(n)) {
    stop(
      "Unknown variant '",
      variant,
      "'. Use 'acefa' or 'mt<N>', e.g. 'mt3'.",
      call. = FALSE
    )
  }
  # mt1 would just rebuild ruarai's own config under a different name. Its results
  # would then sit alongside the real ones when comparing model task counts,
  # looking like a measurement rather than a duplicate.
  if (n < 2L) {
    stop(
      "Variant '",
      variant,
      "' would be the acefa config; use 'acefa' for one modeling task.",
      call. = FALSE
    )
  }
  list(name = variant, n_model_tasks = n)
}

# The L size is meant to be ruarai's hub exactly. If one of the rules above stops
# matching their file then every size is quietly a different hub, so stop with an
# error instead of carrying on.
assert_faithful_to_acefa <- function(acefa) {
  generated <- tier_config(acefa, BENCHMARK_SIZES$L, parse_variant("acefa"))
  if (!identical(generated, acefa)) {
    stop(
      "The L size no longer reproduces acefa-tasks.json. ",
      "A cfg_* rule or the config file has changed.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Submitted data ---------------------------------------------------------------

# The submission covers every model task, so the generators below collect values
# from all of them rather than just the first.
#
# Both the required and the optional values are read. tier_config() only writes
# optional ones today, so reading just those would happen to give the right answer
# rather than being right by design.
task_id_values <- function(task_id) {
  unlist(task_id[c("required", "optional")])
}

union_task_id_values <- function(config, task_id) {
  unique(unlist(lapply(
    config$rounds[[1]]$model_tasks,
    \(mt) task_id_values(mt$task_ids[[task_id]])
  )))
}

union_target_metadata <- function(config) {
  meta <- unlist(
    lapply(config$rounds[[1]]$model_tasks, \(mt) mt$target_metadata),
    recursive = FALSE
  )
  meta[!duplicated(vapply(meta, \(x) x$target_id, character(1)))]
}

# Which target and horizon rows one sample of one unit contains. In ruarai's file
# that is 130: the two targets that forecast ahead, across 64 horizons, plus the
# two that do not (peak size and peak timing) at horizon 0.
#
# Two things are deliberately left out, because their file leaves them out.
# hospital_incidence is allowed by the config but never submitted, and the 7
# earliest horizons go unused. Values that are allowed but not submitted are
# exactly what the "was everything required actually sent?" checks have to work
# out, so the gap has to be there.
make_unit_rows <- function(config) {
  cfg_horizon <- union_task_id_values(config, "horizon")
  data_horizon <- cfg_horizon[-seq_len(7L)]

  meta <- union_target_metadata(config)
  step_ahead <- vapply(meta, \(x) isTRUE(x$is_step_ahead), logical(1))
  target_id <- vapply(meta, \(x) x$target_id, character(1))
  submitted <- target_id != "hospital_incidence"

  rbind(
    expand.grid(
      target = target_id[step_ahead & submitted],
      horizon = data_horizon,
      stringsAsFactors = FALSE
    ),
    expand.grid(
      target = target_id[!step_ahead & submitted],
      horizon = 0L,
      stringsAsFactors = FALSE
    )
  )
}

# The date, location and disease combinations a submission covers. Their file has
# 25 of them, spread over 9 locations and 6 dates, and spread unevenly: each
# location has 1 or 2 dates, and each of those has 1 to 3 diseases. The dates
# differ because every location and disease has its own last day of reliable data.
#
# That unevenness is copied on purpose. A neat set covering every combination is
# the easy case, and the new code should not be judged only on the easy case.
make_units <- function(config, size_spec, round_id, seed = 1L) {
  locations <- union_task_id_values(config, "location")
  pathogens <- union_task_id_values(config, "pathogen")

  # The national total (the first location) is not submitted, matching their file,
  # where 9 of the 10 locations in the config turn up.
  locations <- locations[-1L]

  # The dates fall within roughly the 11 days before the round, and with gaps, as
  # they do in their file.
  candidate_dates <- as.Date(round_id) - seq_len(11L)

  set.seed(seed)
  origin_dates <- sort(sample(candidate_dates, size_spec$data_origin_date))

  # Work through the locations first so every one of them appears, then cut back or
  # top up to exactly `units` combinations.
  triples <- do.call(
    rbind,
    lapply(locations, function(loc) {
      n_dates <- sample(1:2, 1L)
      loc_dates <- sample(origin_dates, min(n_dates, length(origin_dates)))
      do.call(
        rbind,
        lapply(loc_dates, function(d) {
          loc_pathogens <- sample(pathogens, sample(seq_along(pathogens), 1L))
          data.frame(
            origin_date = d,
            location = loc,
            pathogen = loc_pathogens,
            stringsAsFactors = FALSE
          )
        })
      )
    })
  )
  triples <- triples[sample(nrow(triples)), , drop = FALSE]

  if (nrow(triples) >= size_spec$units) {
    triples <- utils::head(triples, size_spec$units)
  } else {
    # Top up from combinations not used yet, so a size can ask for more units than
    # going location by location produced.
    all_triples <- expand.grid(
      origin_date = origin_dates,
      location = locations,
      pathogen = pathogens,
      stringsAsFactors = FALSE
    )
    key <- \(x) paste(x$origin_date, x$location, x$pathogen)
    spare <- all_triples[!key(all_triples) %in% key(triples), , drop = FALSE]
    n_needed <- size_spec$units - nrow(triples)
    if (n_needed > nrow(spare)) {
      stop(
        "Size asks for ",
        size_spec$units,
        " units but the config's value ",
        "space allows only ",
        nrow(triples) + nrow(spare),
        call. = FALSE
      )
    }
    triples <- rbind(
      triples,
      spare[sample(nrow(spare), n_needed), , drop = FALSE]
    )
  }
  triples[order(triples$origin_date, triples$location, triples$pathogen), ]
}

# Which model task each unit belongs to: the one whose allowed values cover the
# unit's values. Because the split above never lets two model tasks overlap,
# exactly one of them matches.
#
# This is needed because one sample id cannot appear in more than one model task
# (check_tbl_spl_mt_unique), and ruarai's file starts its sample ids at 1 again in
# every unit. That is fine when there is only one model task, but under any split
# the same id would turn up in two of them. So each model task gets its own range
# of ids. It is the one place the mt variants have to differ from their file, and
# any real hub with samples and several model tasks has to do the same.
unit_model_task <- function(units, config) {
  model_tasks <- config$rounds[[1]]$model_tasks
  vapply(
    seq_len(nrow(units)),
    function(i) {
      unit <- units[i, ]
      # A unit belongs to a model task when every one of its columns that is also
      # a task ID holds a value that model task allows. Checking all of them,
      # rather than naming the two the split happens to use, keeps this right for
      # any split and means it cannot fall out of step with split_model_tasks().
      matched <- which(vapply(
        model_tasks,
        function(mt) {
          cols <- intersect(names(unit), names(mt$task_ids))
          all(vapply(
            cols,
            \(col) {
              as.character(unit[[col]]) %in%
                as.character(task_id_values(mt$task_ids[[col]]))
            },
            logical(1)
          ))
        },
        logical(1)
      ))
      if (length(matched) != 1L) {
        stop(
          "Unit ",
          unit$location,
          "/",
          unit$pathogen,
          " matches ",
          length(matched),
          " modeling tasks; the split is not disjoint.",
          call. = FALSE
        )
      }
      matched
    },
    integer(1)
  )
}

# Taken from the config rather than written out by hand, so the file we generate
# cannot disagree with the column types check_tbl_col_types() works out from that
# same config. A hand-written version would start failing every size on a
# column-type check the first time a size changed a type or added a task ID.
#
# For ruarai's config this gives their file's types exactly: dates as date32,
# sample ids and values as whole numbers.
benchmark_schema <- function(config) {
  schema <- hubData::create_hub_schema(config)
  # model_id says which model a row came from when reading a whole hub. A single
  # model's own file does not need it.
  schema[names(schema) != "model_id"]
}

# Written one unit at a time, so only one unit is in memory at once rather than the
# whole submission. That matters once a size reaches tens of millions of rows.
write_model_out_file <- function(
  path,
  config,
  unit_rows,
  samples,
  round_id,
  units
) {
  schema <- benchmark_schema(config)
  sink <- arrow::FileOutputStream$create(path)
  writer <- arrow::ParquetFileWriter$create(
    schema,
    sink,
    properties = arrow::ParquetWriterProperties$create(
      column_names = names(schema)
    )
  )
  # Closed at the end rather than only on the way out, so a failure is not hidden.
  # Close() is what writes the file's footer, so ignoring an error there would
  # leave behind a file that cannot be read but looks finished. `closed` stops the
  # on.exit below from closing it a second time when all goes well.
  closed <- FALSE
  on.exit(
    if (!closed) {
      try(writer$Close(), silent = TRUE)
      try(sink$close(), silent = TRUE)
    },
    add = TRUE
  )

  set.seed(2L)
  n_rows <- nrow(unit_rows) * samples
  unit_mt <- unit_model_task(units, config)
  # The same block of target and horizon rows repeats for every unit, so build it
  # once.
  targets <- rep(unit_rows$target, times = samples)
  horizons <- rep(unit_rows$horizon, times = samples)
  for (i in seq_len(nrow(units))) {
    unit <- units[i, ]
    sample_ids <- (unit_mt[i] - 1L) * samples + seq_len(samples)
    chunk <- data.frame(
      round_id = as.Date(round_id),
      origin_date = unit$origin_date,
      target = targets,
      horizon = horizons,
      location = unit$location,
      pathogen = unit$pathogen,
      output_type = "sample",
      output_type_id = rep(sample_ids, each = nrow(unit_rows)),
      value = sample.int(1000L, n_rows, replace = TRUE),
      stringsAsFactors = FALSE
    )
    writer$WriteTable(
      arrow::as_arrow_table(chunk, schema = schema),
      chunk_size = 1e6L
    )
  }
  writer$Close()
  sink$close()
  closed <- TRUE
  invisible(NULL)
}

# Hub assembly ----------------------------------------------------------------

write_admin_config <- function(hub_path, schema_version) {
  admin <- list(
    schema_version = sub("tasks-schema", "admin-schema", schema_version),
    name = "ACEFA benchmark hub",
    maintainer = "hubValidations benchmark",
    contact = list(name = "hubValidations", email = "benchmark@example.com"),
    repository = list(
      host = "github",
      owner = "hubverse-org",
      name = "hubValidations"
    ),
    # An array of one, since file_format is a list in the schema and
    # auto_unbox would otherwise write a bare string.
    file_format = list("parquet"),
    timezone = "Australia/Sydney",
    model_output_dir = "model-output"
  )
  jsonlite::write_json(
    admin,
    file.path(hub_path, "hub-config", "admin.json"),
    auto_unbox = TRUE,
    pretty = TRUE
  )
}

write_model_metadata <- function(hub_path, pkg_dir, team_abbr, model_abbr) {
  # The metadata schema is generic across hubs, so the package's own test-hub
  # copy serves rather than a second copy drifting in _benchmark/.
  file.copy(
    file.path(
      pkg_dir,
      "inst",
      "testhubs",
      "samples",
      "hub-config",
      "model-metadata-schema.json"
    ),
    file.path(hub_path, "hub-config", "model-metadata-schema.json"),
    overwrite = TRUE
  )
  metadata <- c(
    'team_name: "ACEFA benchmark team"',
    sprintf('team_abbr: "%s"', team_abbr),
    'model_name: "ACEFA benchmark model"',
    sprintf('model_abbr: "%s"', model_abbr),
    'model_contributors: [{"name": "hubValidations benchmark", "affiliation": "hubverse", "email": "benchmark@example.com"}]', # nolint: line_length_linter
    'license: "CC-BY-4.0"',
    "designated_model: true",
    'data_inputs: "Synthetic."',
    'methods: "Synthetic samples generated for benchmarking."',
    'methods_long: "Synthetic samples generated for benchmarking hubValidations. Values are random integers and carry no epidemiological meaning."', # nolint: line_length_linter
    "ensemble_of_models: false",
    "ensemble_of_hub_models: false"
  )
  writeLines(
    metadata,
    file.path(
      hub_path,
      "model-metadata",
      sprintf("%s-%s.yml", team_abbr, model_abbr)
    )
  )
}

#' Generate a benchmark hub for one size
#'
#' @param size one of `names(BENCHMARK_SIZES)`.
#' @param variant `"acefa"` for the config as contributed (one modeling task), or
#'   `"mt<N>"` for an N-modeling-task split that exercises assigning data to model
#'   tasks (#355), e.g. `"mt3"` or `"mt10"`.
#' @param hubs_dir parent directory the hub is written under.
#' @param benchmark_dir directory holding `acefa-tasks.json`.
#' @param force regenerate even if the hub is already present. Generation is
#'   deterministic, so an existing hub is reused by default.
#' @return a list describing the hub: `path`, `file_path` (relative to the model
#'   output dir), `round_id`, `variant`, `n_rows` and `n_model_tasks`.
make_benchmark_hub <- function(
  size,
  variant = "acefa",
  hubs_dir = file.path(benchmark_dir, "hubs"),
  benchmark_dir = "_benchmark",
  force = FALSE
) {
  variant_spec <- parse_variant(variant)
  size_spec <- BENCHMARK_SIZES[[size]]
  if (is.null(size_spec)) {
    stop(
      "Unknown size '",
      size,
      "'. Available: ",
      paste(names(BENCHMARK_SIZES), collapse = ", "),
      call. = FALSE
    )
  }
  pkg_dir <- dirname(normalizePath(benchmark_dir, mustWork = TRUE))

  acefa <- read_acefa_config(benchmark_dir)
  assert_faithful_to_acefa(acefa)
  config <- tier_config(acefa, size_spec, variant_spec)

  team_abbr <- "acefa"
  model_abbr <- "sim"
  # A mid-list round, so both earlier and later rounds exist in the config.
  round_ids <- unlist(
    config$rounds[[1]]$model_tasks[[1]]$task_ids$round_id$optional
  ) # nolint: line_length_linter
  round_id <- round_ids[ceiling(length(round_ids) / 2)]
  file_name <- sprintf(
    "%s-%s-%s.parquet",
    round_id,
    team_abbr,
    model_abbr
  )
  file_path <- file.path(sprintf("%s-%s", team_abbr, model_abbr), file_name)

  hub_path <- file.path(
    hubs_dir,
    if (variant == "acefa") size else paste0(size, "-", variant)
  )
  out_file <- file.path(hub_path, "model-output", file_path)

  units <- make_units(config, size_spec, round_id)
  unit_rows <- make_unit_rows(config)
  n_rows <- nrow(units) * nrow(unit_rows) * size_spec$samples

  info <- list(
    path = hub_path,
    file_path = file_path,
    round_id = round_id,
    variant = variant,
    n_rows = n_rows,
    n_model_tasks = length(config$rounds[[1]]$model_tasks)
  )

  if (file.exists(out_file) && !force) {
    return(info)
  }

  dir.create(
    file.path(hub_path, "hub-config"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  dir.create(
    file.path(hub_path, "model-metadata"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)

  # The model-output file is written to a temp path and moved into place only once
  # the configs validate. Its presence is what the reuse guard above tests, so a
  # generation interrupted partway (a Ctrl-C or an OOM during the L or G3 write,
  # which takes minutes) must not leave a truncated file that later runs treat as
  # a complete fixture and benchmark against a row count taken from the size spec.
  staged_file <- paste0(out_file, ".part")
  unlink(staged_file)

  # null = "null" keeps each task ID's `required: null` a JSON null; jsonlite
  # would otherwise write it as {}, which the tasks schema rejects.
  jsonlite::write_json(
    config,
    file.path(hub_path, "hub-config", "tasks.json"),
    auto_unbox = TRUE,
    null = "null",
    pretty = TRUE
  )
  write_admin_config(hub_path, config$schema_version)
  write_model_metadata(hub_path, pkg_dir, team_abbr, model_abbr)
  write_model_out_file(
    staged_file,
    config,
    unit_rows,
    size_spec$samples,
    round_id,
    units
  )

  # A generated hub that isn't a valid hub costs a whole benchmark run to
  # discover, so validate before returning rather than at first use.
  assert_config_valid(hub_path, "tasks")
  assert_config_valid(hub_path, "admin")

  if (!file.rename(staged_file, out_file)) {
    stop("Could not move the generated file to ", out_file, call. = FALSE)
  }

  info
}

assert_config_valid <- function(hub_path, config) {
  valid <- hubAdmin::validate_config(
    hub_path = hub_path,
    config = config,
    schema_version = "from_config"
  )
  if (!isTRUE(valid)) {
    print(attr(valid, "errors"))
    stop(
      "Generated ",
      config,
      " config for hub '",
      hub_path,
      "' is invalid.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
