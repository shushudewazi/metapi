rule cobinning_metabat2_coverage:
    input:
        scaftigs = os.path.join(
            config["output"]["coassembly"],
            "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
        bam = expand(os.path.join(
            config["output"]["coalignment"],
            "bam/{sample}.{{assembler_co}}.out/{sample}.{{assembler_co}}.align2scaftigs.sorted.bam"),
                     sample=SAMPLES.index.unique()),
        bai = expand(os.path.join(
            config["output"]["coalignment"],
            "bam/{sample}.{{assembler_co}}.out/{sample}.{{assembler_co}}.align2scaftigs.sorted.bam.bai"),
                     sample=SAMPLES.index.unique())
    output:
        coverage = os.path.join(
            config["output"]["cobinning"],
            "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.coverage")
    priority:
        30
    log:
        os.path.join(config["output"]["cobinning"],
                     "logs/coverage/all.{assembler_co}.metabat2.coverage.log")
    params:
        percent_identity = config["params"]["binning"]["metabat2"]["percent_identity"],
        min_map_qual = config["params"]["binning"]["metabat2"]["min_map_qual"],
        output_paired_contigs = "--pairedContigs %s" % \
            os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.paired_contigs") \
                if config["params"]["binning"]["metabat2"]["output_paired_contigs"] \
                   else "",
        output_gc = "--outputGC %s" % \
            os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.gc") \
                if config["params"]["binning"]["metabat2"]["output_gc"] \
                   else "",
        output_gc_window = "--gcWindow %s" % \
            os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.gc_window") \
                if config["params"]["binning"]["metabat2"]["output_gc_window"] \
                   else "",
        output_dir = os.path.join(config["output"]["cobinning"],
                                  "coverage/all.{assembler_co}.out")
    shell:
        '''
        jgi_summarize_bam_contig_depths \
        --outputDepth {output.coverage} \
        --percentIdentity {params.percent_identity} \
        --minMapQual {params.min_map_qual} \
        {params.output_paired_contigs} \
        {params.output_gc} \
        {params.output_gc_window} \
        {input.bam} \
        2> {log}
        '''


rule cobinning_metabat2_coverage_all:
    input:
        expand(os.path.join(
            config["output"]["cobinning"],
            "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.coverage"),
               assembler_co=ASSEMBLERS_CO)


rule cobinning_metabat2:
    input:
        scaftigs = os.path.join(
            config["output"]["coassembly"],
            "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
        coverage = os.path.join(
            config["output"]["cobinning"],
            "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.coverage")
    output:
        bins_dir = directory(
            os.path.join(config["output"]["cobinning"],
                         "bins/all.{assembler_co}.out/metabat2"))
    priority:
        30
    log:
        os.path.join(config["output"]["cobinning"],
                     "logs/binning/all.{assembler_co}.metabat2.binning.log")
    params:
        bin_prefix = os.path.join(
            config["output"]["cobinning"],
            "bins/all.{assembler_co}.out/metabat2/all.{assembler_co}.metabat2.bin"),
        min_contig = config["params"]["binning"]["metabat2"]["min_contig"],
        max_p = config["params"]["binning"]["metabat2"]["maxP"],
        min_s = config["params"]["binning"]["metabat2"]["minS"],
        max_edges = config["params"]["binning"]["metabat2"]["maxEdges"],
        p_tnf = config["params"]["binning"]["metabat2"]["pTNF"],
        no_add = "--noAdd" if config["params"]["binning"]["metabat2"]["noAdd"] else "",
        min_cv = config["params"]["binning"]["metabat2"]["minCV"],
        min_cv_sum = config["params"]["binning"]["metabat2"]["minCVSum"],
        min_cls_size = config["params"]["binning"]["metabat2"]["minClsSize"],
        save_cls = "--saveCls" \
            if config["params"]["binning"]["metabat2"]["saveCls"] else "",
        seed = config["params"]["binning"]["metabat2"]["seed"]
    threads:
        config["params"]["binning"]["threads"]
    shell:
        '''
        metabat2 \
        --inFile {input.scaftigs} \
        --abdFile {input.coverage} \
        --outFile {params.bin_prefix} \
        --minContig {params.min_contig} \
        --maxP {params.max_p} \
        --minS {params.min_s} \
        --maxEdges {params.max_edges} \
        --pTNF {params.p_tnf} \
        {params.no_add} \
        --minCV {params.min_cv} \
        --minCVSum {params.min_cv_sum} \
        {params.save_cls} \
        --seed {params.seed} \
        --numThreads {threads} \
        --verbose > {log}
        '''


rule cobinning_metabat2_all:
    input:
        expand(
            os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/metabat2"),
            assembler_co=ASSEMBLERS_CO),

        rules.cobinning_metabat2_coverage_all.input,
        rules.coassembly_all.input


if config["params"]["binning"]["maxbin2"]["do"]:
    rule cobinning_maxbin2_coverage:
        input:
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.coverage")
        output:
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.maxbin2.coverage")
        priority:
            30
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/coverage/all.{assembler_co}.maxbin2.coverage.log")
        shell:
            '''
            cut -f1,3 {input.coverage} | tail -n +2 > {output.coverage}
            '''


    rule cobinning_maxbin2:
        input:
            scaftigs = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.maxbin2.coverage")
        output:
            bins_dir = directory(os.path.join(config["output"]["cobinning"],
                                              "bins/all.{assembler_co}.out/maxbin2"))
        priority:
            30
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/binning/all.{assembler_co}.maxbin2.binning.log")
        params:
            bin_suffix = config["params"]["binning"]["bin_suffix"],
            bin_prefix = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/maxbin2/all.{assembler_co}.maxbin2.bin"),
            min_contig = config["params"]["binning"]["maxbin2"]["min_contig"],
            max_iteration = config["params"]["binning"]["maxbin2"]["max_iteration"],
            prob_threshold = config["params"]["binning"]["maxbin2"]["prob_threshold"],
            plotmarker = "-plotmarker" if config["params"]["binning"]["maxbin2"]["plotmarker"] \
                else "",
            markerset = config["params"]["binning"]["maxbin2"]["markerset"]
        threads:
            config["params"]["binning"]["threads"]
        run:
            import os

            shell('''mkdir -p {output.bins_dir}''')

            shell(
                '''
                set +e

                run_MaxBin.pl \
                -thread {threads} \
                -contig {input.scaftigs} \
                -abund {input.coverage} \
                -min_contig_length {params.min_contig} \
                -max_iteration {params.max_iteration} \
                -prob_threshold {params.prob_threshold} \
                {params.plotmarker} \
                -markerset {params.markerset} \
                -out {params.bin_prefix} \
                -verbose > {log} 2>&1

                exitcode=$?
                if [ $exitcode -eq 1 ]
                then
                    grep -oEi 'Program stop' {log}
                    grepcode=$?
                    if [ $grepcode -eq 0 ]
                    then
                        exit 0
                    else
                        exit $exitcode
                    fi
                fi
                ''')

            with os.scandir(output.bins_dir) as itr:
                for entry in itr:
                    bin_id, bin_suffix = os.path.splitext(entry.name)
                    bin_name, cluster_num = bin_id.rsplit(".", maxsplit=1)
                    bin_id = bin_name + "." + cluster_num.lstrip("0")
                    if bin_suffix == ".fasta":
                        shell('''mv %s %s''' \
                              % (os.path.join(output.bins_dir, entry.name),
                                 os.path.join(output.bins_dir,
                                              bin_id + "." + params.bin_suffix)))


    rule cobinning_maxbin2_all:
        input:
            expand(
                os.path.join(
                    config["output"]["cobinning"],
                    "bins/all.{assembler_co}.out/maxbin2"),
                assembler_co=ASSEMBLERS_CO),

            rules.coassembly_all.input

else:
    rule cobinning_maxbin2_all:
        input:


'''
if config["params"]["binning"]["canopy"]["do"]:
    rule cobinning_canopy_coverage:
        input:
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.metabat2.coverage")
        output:
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.canopy.coverage")
        priority:
            30
        run:
            import pandas as pd

            df = pd.read_csv(input.coverage, sep='\t')
            df.iloc[:, [0, 3]].to_csv(output.coverage, header=None, sep='\t', index=False)
'''


if config["params"]["binning"]["concoct"]["do"]:
    rule cobinning_concoct_coverage:
        input:
            scaftigs = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
            bam = expand(os.path.join(
                config["output"]["coalignment"],
                "bam/{sample}.{{assembler_co}}.out/{sample}.{{assembler_co}}.align2scaftigs.sorted.bam"),
                         sample=SAMPLES.index.unique()),
            bai = expand(os.path.join(
                config["output"]["coalignment"],
                "bam/{sample}.{{assembler_co}}.out/{sample}.{{assembler_co}}.align2scaftigs.sorted.bam.bai"),
                         sample=SAMPLES.index.unique())
        output:
            scaftigs = temp(os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa")),
            scaftigs_cut = temp(os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.cut.fa")),
            scaftigs_bed = temp(os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.cut.bed")),
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.concoct.coverage")
        priority:
            30
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/coverage/all.{assembler_co}.concoct.coverage.log")
        params:
            chunk_size = config["params"]["binning"]["concoct"]["chunk_size"],
            overlap_size = config["params"]["binning"]["concoct"]["overlap_size"]
        threads:
            config["params"]["profiling"]["threads"]
        shell:
            '''
            pigz -p {threads} -k -d -c {input.scaftigs} > {output.scaftigs}

            cut_up_fasta.py \
            {output.scaftigs} \
            --chunk_size {params.chunk_size} \
            --overlap_size {params.overlap_size} \
            --merge_last \
            --bedfile {output.scaftigs_bed} \
            > {output.scaftigs_cut}

            concoct_coverage_table.py \
            {output.scaftigs_bed} \
            {input.bam} \
            > {output.coverage}
            '''


    rule cobinning_concoct:
        input:
            scaftigs = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa"),
            scaftigs_cut = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.cut.fa"),
            scaftigs_bed = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.cut.bed"),
            coverage = os.path.join(
                config["output"]["cobinning"],
                "coverage/all.{assembler_co}.out/all.{assembler_co}.concoct.coverage")
        output:
            bins_dir = directory(os.path.join(config["output"]["cobinning"],
                                              "bins/all.{assembler_co}.out/concoct"))
        priority:
            30
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/binning/all.{assembler_co}.concoct.binning.log")
        params:
            clusters = config["params"]["binning"]["concoct"]["clusters"],
            kmer_length = config["params"]["binning"]["concoct"]["kmer_length"],
            length_threshold = config["params"]["binning"]["concoct"]["length_threshold"],
            read_length = config["params"]["binning"]["concoct"]["read_length"],
            total_percentage_pca = config["params"]["binning"]["concoct"]["total_percentage_pca"],
            iterations = config["params"]["binning"]["concoct"]["iterations"],
            seed = config["params"]["binning"]["concoct"]["seed"],
            no_cov_normalization = "--no_cov_normalization" \
                if config["params"]["binning"]["concoct"]["no_cov_normalization"] \
                   else "",
            no_total_coverage = "--no_total_coverage" \
                if config["params"]["binning"]["concoct"]["no_total_coverage"] \
                   else "",
            no_original_data = "--no_original_data" \
                if config["params"]["binning"]["concoct"]["no_original_data"] \
                   else "",
            coverage_out = "--coverage_out" \
                if config["params"]["binning"]["concoct"]["coverage_out"] \
                   else "",
            bin_suffix = config["params"]["binning"]["bin_suffix"],
            basename = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/concoct/all.{assembler_co}.concoct.bin"),
        threads:
            config["params"]["binning"]["threads"]
        run:
            import os

            shell('''mkdir -p {output.bins_dir}''')

            shell(
                '''
                concoct \
                --threads {threads} \
                --basename {params.basename} \
                --coverage_file {input.coverage} \
                --composition_file {input.scaftigs_cut} \
                --clusters {params.clusters} \
                --kmer_length {params.kmer_length} \
                --length_threshold {params.length_threshold} \
                --read_length {params.read_length} \
                --total_percentage_pca {params.total_percentage_pca} \
                --seed {params.seed} \
                --iterations {params.iterations} \
                {params.no_cov_normalization} \
                {params.no_total_coverage} \
                {params.no_original_data} \
                {params.coverage_out} \
                2> {log}
                ''')

            shell(
                '''
                merge_cutup_clustering.py \
                {params.basename}_clustering_gt1000.csv \
                > {params.basename}_clustering_merged.csv
                ''')

            shell(
                '''
                extract_fasta_bins.py \
                {input.scaftigs} \
                {params.basename}_clustering_merged.csv \
                --output_path {output.bins_dir}
                ''')

            with os.scandir(output.bins_dir) as itr:
                i = 0
                for entry in itr:
                    bin_id, suffix = os.path.splitext(entry.name)
                    if suffix == "." + params.bin_suffix:
                        i += 1
                        shell('''mv %s %s''' \
                              % (os.path.join(output.bins_dir, entry.name),
                                 os.path.join(params.basename + "." + \
                                              str(i) + "." + \
                                              params.bin_suffix)))


    rule cobinning_concoct_all:
        input:
            expand(os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/concoct"),
                   assembler_co=ASSEMBLERS_CO),

            rules.coassembly_all.input

else:
    rule cobinning_concoct_all:
        input:


if config["params"]["binning"]["graphbin"]["do"]:
    rule cobinning_graphbin_prepare_assembly:
        input:
            scaftigs = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
            gfa = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.gfa.gz"),
        output:
             scaftigs = temp(os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/graphbin/scaftigs.fa")),
             gfa = temp(os.path.join(
                 config["output"]["cobinning"],
                 "bins/all.{assembler_co}.out/graphbin/scaftigs.gfa"))
        shell:
            '''
            pigz -dc {input.scaftigs} > {output.scaftigs}
            pigz -dc {input.gfa} > {output.gfa}
            '''


    rule cobinning_graphbin_prepare_binned:
        input:
            bins_dir = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/{binner_graphbin}")
        output:
            binned = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/graphbin/all.{assembler_co}.{binner_graphbin}.graphbin.csv")
        params:
            suffix = config["params"]["binning"]["bin_suffix"],
            assembler_co = "{assembler_co}"
        run:
            metapi.get_binning_info(input.bins_dir,
                                    output.binned,
                                    params.suffix,
                                    params.assembler_co)


    rule cobinning_graphbin:
        input:
            scaftigs = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/graphbin/scaftigs.fa"),
            gfa = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/graphbin/scaftigs.gfa"),
            binned = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/graphbin/all.{assembler_co}.{binner_graphbin}.graphbin.csv")
        output:
            directory(os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/{binner_graphbin}_graphbin"))
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/binning/all.{assembler_co}.{binner_graphbin}.graphbin.refine.log")
        params:
            assembler_co = "{assembler_co}",
            prefix = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/{binner_graphbin}_graphbin/all.{assembler_co}.{binner_graphbin}_graphbin.bin"),
            suffix = config["params"]["binning"]["bin_suffix"],
            paths = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.paths.gz"),
            max_iteration = config["params"]["binning"]["graphbin"]["max_iteration"],
            diff_threshold = config["params"]["binning"]["graphbin"]["diff_threshold"]
        run:
            import pandas as pd
            import os

            shell('''mkdir -p {output}''')

            df = pd.read_csv(input.binned, names=["scaftigs_id", "bin_id"])

            if not df.empty:
                if params.assembler_co == "metaspades" or params.assembler_co == "spades":
                    shell('''pigz -p {threads} -dc {params.paths} > {output}/scaftigs.paths''')
                    shell(
                        '''
                        graphbin \
                        --assembler spades \
                        --graph {input.gfa} \
                        --binned {input.binned} \
                        --paths {output}/scaftigs.paths \
                        --max_iteration {params.max_iteration} \
                        --diff_threshold {params.diff_threshold} \
                        --output {output} > {log} 2>&1
                        ''')
                    shell('''rm -rf {output}/scaftigs.paths''')
                else:
                    shell(
                        '''
                        graphbin \
                        --assembler {params.assembler_co} \
                        --graph {input.gfa} \
                        --contigs {input.scaftigs} \
                        --binned {input.binned} \
                        --max_iteration {params.max_iteration} \
                        --diff_threshold {params.diff_threshold} \
                        --output {output} > {log} 2>&1
                        ''')

                metapi.generate_bins("%s/graphbin_output.csv" % output[0],
                                     input.scaftigs,
                                     params.prefix,
                                     params.suffix)


    rule cobinning_graphbin_all:
        input:
            expand(os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/{binner_graphbin}_graphbin"),
                   binner_graphbin=BINNERS_GRAPHBIN,
                   assembler_co=ASSEMBLERS_CO),

            rules.coassembly_all.input

else:
    rule cobinning_graphbin_all:
        input:


if config["params"]["binning"]["dastools"]["do"]:
    rule cobinning_dastools:
        input:
            bins_dir = expand(
                os.path.join(
                    config["output"]["cobinning"],
                    "bins/all.{{assembler_co}}.out/{binner_dastools}"),
                    binner_dastools=BINNERS_DASTOOLS),
            scaftigs = os.path.join(
                config["output"]["coassembly"],
                "scaftigs/all.{assembler_co}.out/all.{assembler_co}.scaftigs.fa.gz"),
            pep = os.path.join(
                config["output"]["copredict"],
                "scaftigs_gene/all.{assembler_co}.prodigal.out/all.{assembler_co}.faa")
        output:
            bins_dir = directory(os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/dastools"))
        log:
            os.path.join(config["output"]["cobinning"],
                         "logs/binning/all.{assembler_co}.dastools.binning.log")
        priority:
            30
        params:
            search_engine = config["params"]["binning"]["dastools"]["search_engine"],
            write_bin_evals = config["params"]["binning"]["dastools"]["write_bin_evals"],
            write_bins = config["params"]["binning"]["dastools"]["write_bins"],
            write_unbinned = config["params"]["binning"]["dastools"]["write_unbinned"],
            create_plots = config["params"]["binning"]["dastools"]["create_plots"],
            score_threshold = config["params"]["binning"]["dastools"]["score_threshold"],
            duplicate_penalty = config["params"]["binning"]["dastools"]["duplicate_penalty"],
            megabin_penalty = config["params"]["binning"]["dastools"]["megabin_penalty"],
            bin_suffix = config["params"]["binning"]["bin_suffix"],
            bin_prefix = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/dastools/all.{assembler_co}.dastools.bin")
        threads:
            config["params"]["binning"]["threads"]
        run:
            import glob
            import os

            shell('''mkdir -p {output.bins_dir}''')

            binners = []
            tsv_list = []

            for bin_dir in input.bins_dir:
                binner_id = os.path.basename(bin_dir)
                bins_list = glob.glob(bin_dir + "/*.bin.*.fa")

                if len(bins_list) > 0:
                    binners.append(binner_id)
                    tsv_file = "{params.bin_prefix}.%s.scaftigs2bin.tsv" % binner_id
                    tsv_list.append(tsv_file)

                    shell(
                        '''
                        Fasta_to_Scaffolds2Bin.sh \
                        --input_folder %s \
                        --extension {params.bin_suffix} \
                        > %s
                        ''' % (bin_dir, tsv_file))

            if len(binners) > 0:
                shell(
                    '''
                    pigz -p {threads} -d -c {input.scaftigs} > {output.bins_dir}/scaftigs.fasta
                    ''')

                shell(
                    '''
                    set +e

                    DAS_Tool \
                    --bins %s \
                    --labels %s \
                    --contigs {output.bins_dir}/scaftigs.fasta \
                    --proteins {input.pep} \
                    --outputbasename {params.bin_prefix} \
                    --search_engine {params.search_engine} \
                    --write_bin_evals {params.write_bin_evals} \
                    --write_bins {params.write_bins} \
                    --write_unbinned {params.write_unbinned} \
                    --create_plots {params.create_plots} \
                    --score_threshold {params.score_threshold} \
                    --duplicate_penalty {params.duplicate_penalty} \
                    --megabin_penalty {params.megabin_penalty} \
                    --threads {threads} --debug > {log} 2>&1

                    exitcode=$?
                    if [ $exitcode -eq 1 ]
                    then
                        grep -oEi 'Aborting' {log}
                        grepcode=$?
                        if [ $grepcode -eq 0 ]
                        then
                            exit 0
                        else
                            exit $exitcode
                        fi
                    fi
                    ''' % (",".join(tsv_list), ",".join(binners)))

                shell('''rm -rf {output.bins_dir}/scaftigs.fasta''')

                bins_list_dastools = glob.glob(
                    os.path.join(
                        params.bin_prefix + "_DASTool_bins" ,
                        "*." + params.bin_suffix))

                if len(bins_list_dastools):
                    for bin_fa in bins_list_dastools:
                        bin_id = os.path.basename(bin_fa).split(".")[2]
                        bin_fa_ = os.path.basename(bin_fa).replace(bin_id, bin_id +"_dastools")
                        shell('''mv %s %s''' % (bin_fa, os.path.join(output.bins_dir, bin_fa_)))


    rule cobinning_dastools_all:
        input:
            expand(
                os.path.join(
                    config["output"]["cobinning"],
                    "bins/all.{assembler_co}.out/dastools"),
                assembler_co=ASSEMBLERS_CO),

            rules.copredict_scaftigs_gene_prodigal_all.input

else:
    rule cobinning_dastools_all:
        input:


if len(BINNERS_CHECKM) != 0:
    rule cobinning_report:
        input:
            bins_dir = os.path.join(
                config["output"]["cobinning"],
                "bins/all.{assembler_co}.out/{binner_checkm}")
        output:
            report_dir = directory(
                os.path.join(
                    config["output"]["cobinning"],
                    "report/{assembler_co}_{binner_checkm}_stats/all"))
        priority:
            35
        params:
            sample_id = "all",
            assembler_co = "{assembler_co}",
            binner = "{binner_checkm}"
        run:
            import glob

            shell('''rm -rf {output.report_dir}''')
            shell('''mkdir -p {output.report_dir}''')

            bin_list =  glob.glob(input.bins_dir + "/*bin*fa")
            header_list = ["sample_id", "bin_id", "assembler", "binner",
                           "chr", "length", "#A", "#C", "#G", "#T",
                           "#2", "#3", "#4", "#CpG", "#tv", "#ts", "#CpG-ts"]
            header = "\\t".join(header_list)

            for bin_fa in bin_list:
                bin_id = os.path.basename(os.path.splitext(bin_fa)[0])
                header_ = "\\t".join([params.sample_id, bin_id,
                                      params.assembler_co, params.binner])
                stats_file = os.path.join(output.report_dir,
                                          bin_id + ".seqtk.comp.tsv.gz")

                shell(
                    '''
                    seqtk comp %s | \
                    awk \
                    'BEGIN \
                    {{print "%s"}}; \
                    {{print "%s" "\t" $0}}' | \
                    gzip -c > %s
                    ''' % (bin_fa, header, header_, stats_file))


    rule cobinning_report_merge:
        input:
            os.path.join(
                config["output"]["cobinning"],
                "report/{assembler_co}_{binner_checkm}_stats/all")
        output:
            summary = os.path.join(
                config["output"]["cobinning"],
                "report/assembly_stats_{assembler_co}_{binner_checkm}.tsv")
        params:
            len_ranges = config["params"]["assembly"]["report"]["len_ranges"]
        threads:
            config["params"]["binning"]["threads"]
        run:
            import glob
            comp_list = []
            for i in input:
                comp_list += glob.glob(i + "/*bin*.seqtk.comp.tsv.gz")

            if len(comp_list) != 0:
                metapi.assembler_init(params.len_ranges,
                                      ["sample_id", "bin_id", "assembler", "binner"])
                metapi.merge(comp_list, metapi.parse_assembly,
                             threads, output=output.summary)
            else:
                shell('''touch {output.summary}''')


    rule cobinning_report_all:
        input:
            expand(os.path.join(
                config["output"]["cobinning"],
                "report/assembly_stats_{assembler_co}_{binner_checkm}.tsv"),
                   assembler_co=ASSEMBLERS_CO,
                   binner_checkm=BINNERS_CHECKM)

else:
    rule cobinning_report_all:
        input:


rule cobinning_all:
    input:
        rules.cobinning_metabat2_all.input,
        rules.cobinning_maxbin2_all.input,
        rules.cobinning_concoct_all.input,
        rules.cobinning_graphbin_all.input,
        rules.cobinning_dastools_all.input,
        rules.cobinning_report_all.input


rule binning_all:
    input:
        rules.single_binning_all.input,
        rules.cobinning_all.input
