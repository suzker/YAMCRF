# YAMCRF - Yet Another Matlab Conditional Random Field toolkit

> Copyright (c) 2011, Zhiliang Su
> All rights reserved.

## Author: Zhiliang Su
	(zsu2 [at] buffalo [dot] edu)
	University at Buffalo, SUNY
	South China Agricultrual University
	hosted: github.com/suzker

### Change Log
> [25-Mar-2011 21:40:45]
> fast matrix M computation

> [19-Mar-2011 11:52:14]
> fast expectation of feat' func' w.r.t model computation
> demo script added
> viterbi decoding algorithm
> viterbi step size algorithm
> visualization(not functional)

### Structures
> * {1} Folder structure:
> /..
> 	/Data
> 		/TrainData
> 		/TestData
> 		/RawData
>       /MatrixM
> 	/Common
> 	/Optimizer
> 		/GIS
> 		/IIS
> 		/LBFGS
>	/Optimizer-Common
>	/Decoder
>	/BP
>	/Viterbi
>	/Decoder-common
>	/DOC
>	- CRFdemo.m
>	- README.md

> * {2} Configuration file structure:

> * {3} Model file structure:

		|               |- LBFGS
		|               |- IIS
		|- Optimizer....|- GIS
		|- Decoder
		|- Data ........|- Nx
		|               |- Ny
		|               |- Xtype
		|               |- Ytype

## Credits
> ### - fminlbfgs - a LBFGS implementation for MATALB by Dirk-Jan Kroon
> 
> Copyright (c) 2009, Dirk-Jan Kroon
> All rights reserved.
> 
> Redistribution and use in source and binary forms, with or without 
> modification, are permitted provided that the following conditions are 
> met:
>
>     * Redistributions of source code must retain the above copyright 
>     notice, this list of conditions and the following disclaimer.
>     * Redistributions in binary form must reproduce the above copyright 
>       notice, this list of conditions and the following disclaimer in 
>       the documentation and/or other materials provided with the distribution
      
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
> AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
> IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
> ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
> LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
> CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
> SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
> INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
> CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
> ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
> POSSIBILITY OF SUCH DAMAGE.
