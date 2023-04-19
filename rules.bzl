def _genfoo(ctx):
    outdir = ctx.actions.declare_directory(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [outdir],
        inputs = ctx.files.srcs,
        command = """
        for ((n=0;n<10;n++)); do
            echo $n > {0}/$n
        done
        """.format(outdir.path),
    )
    return [DefaultInfo(files = depset([outdir]))]

genfoo = rule(
    _genfoo,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)
