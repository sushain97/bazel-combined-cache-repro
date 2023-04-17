def _genfoo(ctx):
    outdir = ctx.actions.declare_directory(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [outdir],
        command = "echo a > {0}/a; echo b > {0}/b".format(outdir.path),
    )
    return [DefaultInfo(files = depset([outdir]))]

genfoo = rule(
    _genfoo,
)
