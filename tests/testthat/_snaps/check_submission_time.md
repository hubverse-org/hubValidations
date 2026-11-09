# resolve_hub_timezone errors for an unrecognised timezone

    Code
      resolve_hub_timezone("Mars/Olympus_Mons")
    Condition
      Error:
      ! Hub timezone "Mars/Olympus_Mons" is not recognised on this system.
      i Check that timezone in 'hub-config/admin.json' is a valid tz database name, such as "America/New_York", and that the system has a timezone database (tzdata) installed.

---

    Code
      resolve_hub_timezone("Canada/Pacific")
    Condition
      Error:
      ! Hub timezone "Canada/Pacific" is not recognised on this system.
      i Check that timezone in 'hub-config/admin.json' is a valid tz database name, such as "America/Vancouver", and that the system has a timezone database (tzdata) installed.

