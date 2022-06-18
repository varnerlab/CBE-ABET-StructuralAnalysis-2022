### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 2dd9b648-636b-4e56-989a-00c32f95eea9
begin

	# Julia setup: load the required Julia packages -
	using DataFrames
	using CSV
	using LinearAlgebra
	using Statistics
end

# ╔═╡ 41d68deb-3426-4586-a085-7e6fe19be8b4
md"""
### Structural Analysis of the Smith School of Chemical and Biomolecular Engineering Curriculum
Jeffrey D Varner, Professor, Robert Frederick Smith School of Chemical and Biomolecular Engineering
"""

# ╔═╡ 1fd0757b-537b-4e61-bebf-d7da7f00d2ed
md"""
##### Modeling the relationship between courses and performance indicators
The course mapping matrix $M$ related the courses taught in the core curriculum of the Smith School to the performance indicators (PIs) developed by the College of Engineering Educational Assessment Committee (COEEAC). The mapping matrix $M$ was constructed using the instructor-generated self-assessments for each CBE course. The course mapping matrix $M$ is a $\mathcal{C}\times\mathcal{P}$ binary matrix, where $\mathcal{C}$ denotes the number of courses. In contrast, $\mathcal{P} $ denotes the number of performance indicators used for assessment. The $(i,j)$ value of $M$, denoted by $m_{ij}$ can take on two values, $0$ or $1$:

$$m_{ij} = 
\begin{cases}
	1 & \text{if course i assessed using performance indicator j} \\
	0 & \text{if course i not assessed using performance indicator j}
\end{cases}$$

Thus, the rows of the matrix $M$ correspond to the CBE courses assessed in this cycle $\mathcal{C} = 12$, while the columns correspond to COEEAC performance indicators $\mathcal{P} = 17$. Operations on the matrix $M$ can give structural information about the CBE program and how it is assessed. 

__Course connectivity array (CCA)__: The product of the matrix $M$ with its transpose (denoted by $\star^{T}$) gives the $\mathcal{C}\times\mathcal{C}$ course connectivity array (CCA):

$$CCA \equiv MM^{T}$$

The diagonal entries of $CCA$ describe the number of PIs used to assess that course. In contrast, off-diagonal elements of $CCA$ describe the number of shared PIs between classes $i$ and $j$, where $i\neq{j}$. Thus, $CCA$ helps determine the assessment coverage for a particular course and the assessment relationship between classes.


__Performance Indicator connectivity array (PICA)__: The product of the transpose of the mapping matrix $M^{T}$ with its itself:

$$PICA \equiv M^{T}M$$

gives the $\mathcal{P}\times\mathcal{P}$ performance indicator connectivity array (PICA). The diagonal entries of $PICA$ describe the number of courses that used a particular PI. On the other hand, the off-diagonal elements of $PICA$ represent the number of shared classes between performance indicator $i$ and $j$, where $i\neq{j}$.

"""

# ╔═╡ f3263a91-6989-4fb8-9092-bf048fe0096e
begin

	# path to the binary M matrix -
	path_to_data_file = joinpath(pwd(),"data","Course-Binary-Array-Connectivity-Array.csv")
	
	# load the data as a DataFrame -
	df = CSV.read(path_to_data_file,DataFrame)

	# create the mapping matrix M -
	M = Matrix(df[!,5:end])

	# show -
	nothing 
end

# ╔═╡ 41de88b3-c1d4-494b-aa53-cff07e4b58c1
# compute the course connectivity array -
CCA = M*transpose(M)

# ╔═╡ 98830429-e731-4915-9a3e-3f1640d810c4
# compute the PI connectivity array (PICA) -
PICA = transpose(M)*M

# ╔═╡ 10f76d44-1473-40bd-ad94-97c3ba0b5668
md"""
##### Modeling the relationship between courses and student outcomes
The mapping matrix $M$ relates $\mathcal{C}$ courses to $\mathcal{P}$ performance indicators. However, to explore the relationship between classes and program educational outcomes (PEOs), we need to map the $\mathcal{P}$ performance indicators to the $\mathcal{S}$ student outcomes. The College of Engineering Educational Assessment Committee (COEEAC) already developed these relationships, which we encode in the $\mathcal{S}\times{P}$ matrix $L$: 

$$l_{ij} = 
\begin{cases}
	\alpha & \text{if student outcome i is connected with performance indicator j} \\
	0 & \text{if student outcome i is connected with performance indicator j}
\end{cases}$$

where $\alpha$ denotes the fraction of outcome $i$ represented by performance indicator $j$. We assume that each performance indicator contributes equally to each student outcome. Thus, if the set of performance indicators belonging to a particular student outcome has $n$ elements, then $\alpha = 1/n$,

The $\mathcal{S}\times\mathcal{P}$ student outcomes matrix $S$ is given by:

$$S = LM^{T}$$

Connectivity analysis of the matrix $S$ gives us insights into share outcomes:
* The $SS^{T}$ array with dimension $\mathcal{S}\times\mathcal{S}$ holds information about the number of outcomes per course (diagonal) and the shared outcomes between class $i$ and $j$, where $i\neq{j}$.
* The $S^{T}S$ array with dimension $\mathcal{C}\times\mathcal{C}$  holds information about the number of courses per outcome (diagonal) and classes shared between outcomes $i$ and $j$, where $i\neq{j}$
"""

# ╔═╡ 7df2a516-9954-43bf-b5af-0d0c7c940270
begin

	# path to binary PEO to SO array -
	path_to_outcomes_PI_data_file = joinpath(pwd(),"data","Outcomes-PI-BinaryMapping-Array.csv")

	# load the data as a DataFrame -
	df_so_pi = CSV.read(path_to_outcomes_PI_data_file, DataFrame)

	# generate the PEO matrix P -
	L = Matrix(df_so_pi[!,2:end])
	
	# show -
	nothing 
end

# ╔═╡ 70a3f9d0-6be4-42f4-89b6-daf45a3b0202
S = L*transpose(M)

# ╔═╡ 8b0642d8-5cff-440f-973e-5c28395a620b
S*transpose(S)

# ╔═╡ 76e6c96c-fca0-4e6c-8f78-d859f922f265
md"""
##### Modeling the relationship between student outcomes and program educational outcomes (PEO)
"""

# ╔═╡ 78c39051-c596-4c30-9b75-fa388157bc39
begin

	# path to binary PEO to SO array -
	path_to_peo_data_file = joinpath(pwd(),"data","BinaryMapping-PEOs-to-SO.csv")

	# load the data as a DataFrame -
	df_peo = CSV.read(path_to_peo_data_file, DataFrame)

	# generate the PEO matrix P -
	P = Matrix(df_peo[!,2:end])
	
	# show -
	nothing 
end

# ╔═╡ 4e0f0d59-4e91-47ff-8b74-ec544c246e9c
T = P*S

# ╔═╡ 8383bef6-8bcc-492c-8a6f-0eef1280b8e7
begin	
	R = sum(T,dims=2)
	Z = sum(R)
	Rₛ = (1/Z)*R
end

# ╔═╡ a45da81a-edb4-11ec-2f66-2b11954e62aa
html"""
<style>
main {
    max-width: 1200px;
    width: 75%;
    margin: auto;
    font-family: "Roboto, monospace";
}
a {
    color: blue;
    text-decoration: none;
}
.H1 {
    padding: 0px 30px;
}
</style>"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CSV = "~0.10.4"
DataFrames = "~1.3.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "9be8be1d8a6f44b96482c8af52238ea7987da3e3"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.45.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "db8481cf5d6278a121184809e9eb1628943c7704"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.13"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─41d68deb-3426-4586-a085-7e6fe19be8b4
# ╠═2dd9b648-636b-4e56-989a-00c32f95eea9
# ╟─1fd0757b-537b-4e61-bebf-d7da7f00d2ed
# ╠═f3263a91-6989-4fb8-9092-bf048fe0096e
# ╠═41de88b3-c1d4-494b-aa53-cff07e4b58c1
# ╠═98830429-e731-4915-9a3e-3f1640d810c4
# ╟─10f76d44-1473-40bd-ad94-97c3ba0b5668
# ╠═7df2a516-9954-43bf-b5af-0d0c7c940270
# ╠═70a3f9d0-6be4-42f4-89b6-daf45a3b0202
# ╠═8b0642d8-5cff-440f-973e-5c28395a620b
# ╟─76e6c96c-fca0-4e6c-8f78-d859f922f265
# ╠═78c39051-c596-4c30-9b75-fa388157bc39
# ╠═4e0f0d59-4e91-47ff-8b74-ec544c246e9c
# ╠═8383bef6-8bcc-492c-8a6f-0eef1280b8e7
# ╟─a45da81a-edb4-11ec-2f66-2b11954e62aa
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
