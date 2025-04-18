% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_tbl_value_col.R
\name{check_tbl_value_col}
\alias{check_tbl_value_col}
\title{Check output type values of model output data against config}
\usage{
check_tbl_value_col(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
)
}
\arguments{
\item{tbl}{a tibble/data.frame of the contents of the file being validated.}

\item{round_id}{character string. The round identifier.}

\item{file_path}{character string. Path to the file being validated relative to
the hub's model-output directory.}

\item{hub_path}{Either a character string path to a local Modeling Hub directory
or an object of class \verb{<SubTreeFileSystem>} created using functions \code{\link[hubData:s3_bucket]{s3_bucket()}}
or \code{\link[hubData:gs_bucket]{gs_bucket()}} by providing a string S3 or GCS bucket name or path to a
Modeling Hub directory stored in the cloud.
For more details consult the
\href{https://arrow.apache.org/docs/r/articles/fs.html}{Using cloud storage (S3, GCS)}
in the \code{arrow} package.
The hub must be fully configured with valid \code{admin.json} and \code{tasks.json}
files within the \code{hub-config} directory.}

\item{derived_task_ids}{Character vector of derived task ID names (task IDs whose
values depend on other task IDs) to ignore. Columns for such task ids will
contain \code{NA}s. Defaults to extracting derived task IDs from hub \code{task.json}. See
\code{\link[=get_hub_derived_task_ids]{get_hub_derived_task_ids()}} for more details.}
}
\value{
Depending on whether validation has succeeded, one of:
\itemize{
\item \verb{<message/check_success>} condition class object.
\item \verb{<error/check_failure>} condition class object.
}

Returned object also inherits from subclass \verb{<hub_check>}.
}
\description{
Checks that values in the \code{value} column of a tibble/data.frame of data read
in from the file being validated conform to the configuration for each output
type of the appropriate model task.
}
