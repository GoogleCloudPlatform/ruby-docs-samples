# Google Cloud Storage Ruby sample

To run, first install dependencies

    bundle install

Then run the `bundle exec buckets`

    NAME
        buckets - Manage Google Cloud Storage buckets

    SYNOPSIS
        buckets [global options] command [command options] [arguments...]

    GLOBAL OPTIONS
        --help                      - Show this message
        -p, --project-id=PROJECT_ID - Your Google Cloud project ID (default: none)

    COMMANDS
        create - Create a new bucket with the given name
        delete - Delete the specified bucket.
        help   - Shows a list of commands or help for one command
        list   - List all buckets in the authenticated project
