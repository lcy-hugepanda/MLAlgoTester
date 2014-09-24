**MLAlgoTester**
----

MLAlgoTester (Machine Learning Algorithm Tester, MLAT) is an automatic evaluating framework for machine learning algorithms

----
**Short tutorial of MLAT**<br>
1. Save all datasets (to be evaluated) in the 'datasets' folder.<br>
2. Edit 'conf.m' to guide the evaluating procedure<br>
&emsp;	2a. Edit "dataset_list" to specify the datasets used in the next run.<br>
&emsp;	2b. Edit "algo_list" to specify the algorithms used in the next run.<br>
&emsp;	2c. Edit "error_computation_list" to specify the evaluating criteria used in the next run.<br>
3. Run 'main.m' in MATLAB.<br>
4. Retrive results in 'temp.mat'<br>

----
**Tips**<br>
- Datasets used in MLAT must be formatted in PRTools5 style. Save the prdataset data structure in the .mat file with name 'x'. (For details of PRTools, please visit [www.37steps.com](www.37steps.com))<br>
- To run the MATLAB version of MLAT, Please download PRTools5 from [here](http://prtools.org) first. <br>
- To test one-class learning algorithms using the MATLAB version of MLAT, please download dd_tools (version 2.0.2 or above) from [here](http://prlab.tudelft.nl/david-tax/dd_tools.html).

----
**Dependence (for MATLAB implementation)**<br>
- PRTools is a pattern recognition toolbox in MATLAB maintained by [37steps](http://www.37steps.com). Note that PRTools is NOT an open source software, the copyright is hold by [37steps](http://www.37steps.com).<br>
- dd_tools is a wonderful open source data description toolboxs written by [David Tax](http://prlab.tudelft.nl/users/david-tax).<br>
&emsp;	{Tax, D.M.J., DDtools, the Data Description Toolbox for Matlab, version 2.0.2, 2013}

----
**History**<br>
 - 2013-11-4 Repo created
