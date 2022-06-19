### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ bece9725-e7d5-411d-b5a2-957e8166d074
begin

	# Julia setup: load the required Julia packages -
	using DataFrames
	using CSV
	using LinearAlgebra
	using Statistics
	using PlutoUI
	using PrettyTables
	using StatsBase
end

# ╔═╡ b74a5af6-eaf9-4e90-a3ff-4e2d33b4efef
md"""
## Assessment Gap Analysis of the Smith School of Chemical and Biomolecular Engineering Curriculum
Jeffrey D Varner, Professor, Robert Frederick Smith School of Chemical and Biomolecular Engineering
"""

# ╔═╡ 618126fe-2448-42e6-8adf-0eecf3638e93
md"""
### Modeling the relationship between courses and student outcomes 
The course mapping matrix $M$ relates the courses taught in the core curriculum of the Smith School to the performance indicators (PIs) developed by the College of Engineering Educational Assessment Committee (COEEAC). The mapping matrix $M$ was constructed using the instructor-generated self-assessments for each CBE course. The course mapping matrix $M$ is a $\mathcal{C}\times\mathcal{P}$ binary matrix, where $\mathcal{C}$ denotes the number of courses. In contrast, $\mathcal{P} $ denotes the number of performance indicators used for assessment. The $(i,j)$ value of $M$, denoted by $m_{ij}$ can take on two values, $0$ or $1$:

$$m_{ij} = 
\begin{cases}
	1 & \text{if course i assessed using performance indicator j} \\
	0 & \text{if course i not assessed using performance indicator j}
\end{cases}$$

Thus, the rows of the matrix $M$ correspond to the CBE courses assessed in this cycle $\mathcal{C} = 12$, while the columns correspond to COEEAC performance indicators $\mathcal{P} = 17$. Operations on the matrix $M$ can give structural information about the CBE program and how it is assessed. 

The mapping matrix $M$ relates $\mathcal{C}$ courses to $\mathcal{P}$ performance indicators. However, to explore the relationship between classes and program educational outcomes (PEOs), we need to map the $\mathcal{P}$ performance indicators to the $\mathcal{S}$ student outcomes and from there to the performance indicators. The College of Engineering Educational Assessment Committee (COEEAC) has already developed the relationships between student outcomes and performance indicators, which we encode in the $\mathcal{S}\times{P}$ matrix $L$: 

$$l_{ij} = 
\begin{cases}
	\alpha & \text{if student outcome i is connected with performance indicator j} \\
	0 & \text{if student outcome i is not connected with performance indicator j}
\end{cases}$$

where $\alpha$ denotes the fraction of outcome $i$ represented by performance indicator $j$; for simplicity, we assume that each performance indicator contributes equally to each student outcome. Thus, if the set of performance indicators belonging to a particular student outcome has $n$ elements, then $\alpha = 1/n$,

The $\mathcal{S}\times\mathcal{C}$ student outcomes matrix $S$ is given by:

$$S = LM^{T}$$
"""

# ╔═╡ 2ad2609b-947f-4a76-beec-059cf037f8df
begin

	# paths to data files -
	path_to_course_PI_data_file = joinpath(pwd(),"data","Course-Binary-Array-Connectivity-Array.csv")
	path_to_outcomes_PI_data_file = joinpath(pwd(),"data","Outcomes-PI-BinaryMapping-Array.csv")

	# load the data as a DataFrame -
	df_course_pi = CSV.read(path_to_course_PI_data_file, DataFrame)
	df_so_pi = CSV.read(path_to_outcomes_PI_data_file, DataFrame)
	
	# generate the M and L matricies -
	L = Matrix(df_so_pi[!,2:end])
	M = Matrix(df_course_pi[!,5:end])
	
	# compute the S matrix -
	S = L*transpose(M)

	# show -
	nothing 
end

# ╔═╡ d506c21b-0a90-480f-8c19-3adfc6b1b06d
df_course_pi

# ╔═╡ 1db0c5d1-ddb4-4ba0-8858-2774fbac9cbb
S

# ╔═╡ c9d6a1eb-80e5-4a83-a55f-927be3f7fa61
md"""
### Observable Assesment Gaps
The student outcomes array $S$ is a $\mathcal{S}\times\mathcal{C}$ matrix whose $(i,j)$-th entry describes the fraction of assessments used by each class. For example, $s_{1,1} = 1.0$, which says that ENGRI-1120 (index 1 of the list of courses) fully assesses outcome 1 (the ENGRI-1120 self-assessment used all the performance indicators associated for student outcome-1 to measure student achievement). However, $s_{3,1} = 0.33$ says that ENGRI-1120 did not fully assess student achievement with respect to student outcome 3 (only one of three possible performance indicators was evaluated); thus, is an __observable assessment gap__ of $g_{3,1} = 0.67$, where $g_{ij}$ denotes the $(i,j)$-th element of the observable assessment gap matrix $G$.

To compute the observable assessment gap matrix $G$, we find the indices of all non-zero values of the student outcomes array $S$ and then subtract these values from 1; this difference gives the fraction of possible assessment tools available for a student outcome. 
"""

# ╔═╡ 448950d1-d8d1-4a52-8437-0d408d2cb922
begin

	# get size of S -
	(𝒮,𝒞) = size(S)
	G = Array{Float64,2}(undef, 𝒮, 𝒞)
	fill!(G, 0.0) # initialize all the entries to zero -
	
	# compute the gap -
	for i ∈ 1:𝒮
		for j ∈ 1:𝒞
			G[i,j] = 1 - S[i,j]
		end
	end
end

# ╔═╡ 0dd3376d-fea4-47cf-9f92-ee2f24a48c62
with_terminal() do

	# build a pretty table that holds the assessment gap for each course -
	data_table = Array{Any,2}(undef, 𝒞+1, (𝒮 + 1))

	# put the names of the courses in the first col -
	for i ∈ 1:𝒞
		data_table[i,1] = df_course_pi[i, :Courses]
	end
	data_table[end,1] = "gap"

	# compute the T -
	T = (1/𝒞).*sum(G, dims=2)

	# build the header_row -
	header_row = ["Course", "O₁", "O₂", "O₃", "O₄", "O₅", "O₆", "O₇"]

	# next, copy in the G entries -
	for o ∈ 1:𝒮
		for c ∈ 1:𝒞
			data_table[c,(o+1)] = G[o,c]
		end
	end

	for o ∈ 1:𝒮
		data_table[end,o+1] = T[o]
	end
	

	
	pretty_table(data_table; header=header_row)
end

# ╔═╡ d4e684a8-6a06-43f9-a140-e4c52ca94e80
md"""
### Modeling the relationship between courses and program educational objectives
The central question we seek to answer is whether our courses and their associated assessment regime support the current program educational objectives (PEOs) for the Smith School. Toward this question, we will construct and analyze the entries of the program matrix $P$, a $\mathcal{O}\times\mathcal{C}$ matric whose $(i,j)$-th entry describes how course $j$ contributes to outcome $i$. We compute the program matrix $P$ as:

$$P = TS$$

where $T$ is a $\mathcal{O}\times{S}$ mapping matrix which relates the program educational objectives (rows) to the ABET student outcomes (cols). The $(i,j)$-th element of $T$, denoted by $t_{ij}$ is defined as:

$$t_{ij} = 
\begin{cases}
	\beta & \text{if PEO i is connected with student outcome j} \\
	0 & \text{if PEO i is not connected with student outcome j}
\end{cases}$$

where $\beta$ denotes the fraction of program educational objective $i$ represented by student outcome $j$; for simplicity, we assume that each student outcome contributes equally to a program educational objective. Thus, if the set of student outcomes belonging to a particular program educational objective has $n$ elements, then $\beta = 1/n$,
"""

# ╔═╡ 53edec60-0309-49d2-a2d3-5e8e86d33ed3
begin

	# path to binary PEO to SO array -
	path_to_peo_data_file = joinpath(pwd(),"data","BinaryMapping-PEOs-to-SO.csv")

	# load the data as a DataFrame -
	df_peo = CSV.read(path_to_peo_data_file, DataFrame)

	# generate the PEO matrix P -
	T = Matrix(df_peo[!,2:end])
	
	# show -
	nothing 
end

# ╔═╡ 155efa43-6b62-42cc-b47a-6f6664dbb56a
P = T*S

# ╔═╡ e1359301-f08e-405e-a086-2795e1366ace
with_terminal() do

	# what is the size of the P matrix -
	(𝒪,𝒞) = size(P)
	
	# compute scaled score -
	R = sum(P,dims=2)
	Z = sum(R)
	Rₛ = (1/Z).*R

	# sort index -
	sort_index = sortperm(Rₛ[:]; rev=true)

	sorted_Rₛ = Rₛ[sort_index]
	
	# initialize -
	data_table = Array{Any,2}(undef, 𝒪, 𝒞 + 3)
	obj_string_array = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"]

	# add scaled values -
	for o ∈ 1:𝒪
		
		# setup first two cols -
		data_table[o,1] = obj_string_array[sort_index[o]]
		data_table[o,2] = sorted_Rₛ[o]*(1/sorted_Rₛ[1])
		data_table[o,3] = o

		rank_array = ordinalrank(P[sort_index[o],:]; rev=true)
		for r ∈ 1:𝒞
			data_table[o,r+3] = rank_array[r]
		end
	end

	header_row = ["PEO", "Score", "Rank", "ENGRI-1120", "ENGRG-2190", "CHEME-2880", "CHEME-3230", "CHEME-3130", 
		"CHEME-3240", "CHEME-3320", "CHEME-3720", "CHEME-3900", "CHEME-4320", "CHEME-4610", "CHEME-4620"]
	pretty_table(data_table; header=header_row)
end

# ╔═╡ 7044bfb3-08d5-49d6-8017-63a156a8b5d8
TableOfContents(title="📚 Table of Contents", indent=true, depth=5, aside=true)

# ╔═╡ fe434898-efef-11ec-25c2-eb441ffd2bb6
html"""
<style>
main {
    max-width: 1200px;
    width: 65%;
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

# ╔═╡ b52fe0d7-3742-468d-93ae-5052d72a5039
html"""
<script>
	// initialize -
	var section = 0;
	var subsection = 0;
	var headers = document.querySelectorAll('h3, h4');
	
	// main loop -
	for (var i=0; i < headers.length; i++) {
	    
		var header = headers[i];
	    var text = header.innerText;
	    var original = header.getAttribute("text-original");
	    if (original === null) {
	        
			// Save original header text
	        header.setAttribute("text-original", text);
	    } else {
	        
			// Replace with original text before adding section number
	        text = header.getAttribute("text-original");
	    }
	
	    var numbering = "";
	    switch (header.tagName) {
	        case 'H3':
	            section += 1;
	            numbering = section + ".";
	            subsection = 0;
	            break;
	        case 'H4':
	            subsection += 1;
	            numbering = section + "." + subsection;
	            break;
	    }
		// update the header text 
		header.innerText = numbering + " " + text;
	};
</script>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CSV = "~0.10.4"
DataFrames = "~1.3.4"
PlutoUI = "~0.7.39"
PrettyTables = "~1.3.1"
StatsBase = "~0.33.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

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

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9489214b993cd42d17f44c36e359bf6a7c919abf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "1e315e3f4b0b7ce40feded39c73049692126cf53"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.3"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

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

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

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

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

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

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "09e4b894ce6a976c354a69041a04748180d43637"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.15"

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

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

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

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "2c11d7290036fe7aac9038ff312d3b3a2a5bf89e"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.4.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

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

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

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
# ╟─b74a5af6-eaf9-4e90-a3ff-4e2d33b4efef
# ╠═bece9725-e7d5-411d-b5a2-957e8166d074
# ╟─618126fe-2448-42e6-8adf-0eecf3638e93
# ╠═2ad2609b-947f-4a76-beec-059cf037f8df
# ╠═d506c21b-0a90-480f-8c19-3adfc6b1b06d
# ╠═1db0c5d1-ddb4-4ba0-8858-2774fbac9cbb
# ╟─c9d6a1eb-80e5-4a83-a55f-927be3f7fa61
# ╠═448950d1-d8d1-4a52-8437-0d408d2cb922
# ╟─0dd3376d-fea4-47cf-9f92-ee2f24a48c62
# ╟─d4e684a8-6a06-43f9-a140-e4c52ca94e80
# ╠═53edec60-0309-49d2-a2d3-5e8e86d33ed3
# ╠═155efa43-6b62-42cc-b47a-6f6664dbb56a
# ╠═e1359301-f08e-405e-a086-2795e1366ace
# ╟─7044bfb3-08d5-49d6-8017-63a156a8b5d8
# ╟─fe434898-efef-11ec-25c2-eb441ffd2bb6
# ╟─b52fe0d7-3742-468d-93ae-5052d72a5039
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
