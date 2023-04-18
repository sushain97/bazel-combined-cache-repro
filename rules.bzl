def _genfoo(ctx):
    outdir = ctx.actions.declare_directory(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [outdir],
        command = """
        for ((n=0;n<5000;n++)); do
            echo $n > {0}/$n
        done
        """.format(outdir.path),
    )
    return [DefaultInfo(files = depset([outdir]))]

genfoo = rule(
    _genfoo,
)
