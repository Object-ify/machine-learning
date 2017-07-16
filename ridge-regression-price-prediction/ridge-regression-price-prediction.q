/ Ridge, L2 regression
ridgeregression:{[f;op;tl;s;counter]niter {
    w::w-s*((2*(flip f)$((f$w)-op))+(2*l2_p*w))} \ counter;
    };

/ Clean the dataset.
cleandataset:{[tf]
    ds::delete Id from ds;
    
    / Change 1stFlrSF and 2ndFlrSF to q-type variables
    t:key ft:flip ds;
    t[where t=`1stFlrSF]:`FstFlrSF;
    t[where t=`2ndFlrSF]:`SndFlrSF;
    t[where t=`3SsnPorch]:`ThreeSnPorch;
    ds::flip t!value ft;

    / Non-categorical columns, not to be passed for one-hot encoding
    remCols:`YearBuilt`YearRemodAdd`LotArea`MasVnrArea`BsmtFinSF1`BsmtFinSF2`BsmtUnfSF`TotalBsmtSF`FstFlrSF`SndFlrSF`LowQualFinSF`GrLivArea`BsmtFullBath`BsmtHalfBath`FullBath`HalfBath`BedroomAbvGr`KitchenAbvGr`TotRmsAbvGrd`Fireplaces`GarageYrBlt`GarageCars`GarageArea`WoodDeckSF`OpenPorchSF`EnclosedPorch`ThreeSnPorch`ScreenPorch`PoolArea`MiscVal`MoSold`YrSold`SalePrice;
    
    / If it is test dataset remove the SalePrice column
    if[tf like "test";remCols:remCols[where remCols<>`SalePrice]];
    
    / Remove all non-cat columns from list, 
    / so we're sending only cats to one-hot
    tmp:cols ds;
    tmp:tmp[where not tmp in\: remCols];

    / Find all categorical columns with NAs, 
    / remove NAs and create a dict with distinct values in each column
    kna:k[wk:where  (`NA in/: k:distinct each ds[tmp])];
    t:0,(+\)t[til(-1+count t:count each where each `NA <> kna)];
    rkna:raze kna;
    e:(tmp)[wk] ! t cut rkna[where rkna <> `NA];
    k[wk]:e@(tmp)[wk];
    k:(tmp) ! k;

    i:0;
    while[i<count k;
        ds::ds,'((`$( string (key k)[i]) ,/: string (value k)[i])!)each s:((count ds),(count r:where each (value k)[i] =\: ds[key k][i]))#0;
        s[r[i];i]:1;
        i:i+1;
    ];

    / Delete original non-one-hot categorical columns
    ds::![ds;();0b;tmp];

    / Re-append non-categorical columns
    ds::ds,'flip remCols ! ds[remCols];

    / Create a alias to cleaned up datased
    $[tf like "train"; train::ds; test::ds]
    
    };

/ Columns names
colnames:`Id`MSSubClass`MSZoning`LotFrontage`LotArea`Street`Alley`LotShape`LandContour`Utilities`LotConfig`LandSlope`Neighborhood`Condition1`Condition2`BldgType`HouseStyle`OverallQual`OverallCond`YearBuilt`YearRemodAdd`RoofStyle`RoofMatl`Exterior1st`Exterior2nd`MasVnrType`MasVnrArea`ExterQual`ExterCond`Foundation`BsmtQual`BsmtCond`BsmtExposure`BsmtFinType1`BsmtFinSF1`BsmtFinType2`BsmtFinSF2`BsmtUnfSF`TotalBsmtSF`Heating`HeatingQC`CentralAir`Electrical`1stFlrSF`2ndFlrSF`LowQualFinSF`GrLivArea`BsmtFullBath`BsmtHalfBath`FullBath`HalfBath`BedroomAbvGr`KitchenAbvGr`KitchenQual`TotRmsAbvGrd`Functional`Fireplaces`FireplaceQu`GarageType`GarageYrBlt`GarageFinish`GarageCars`GarageArea`GarageQual`GarageCond`PavedDrive`WoodDeckSF`OpenPorchSF`EnclosedPorch`3SsnPorch`ScreenPorch`PoolArea`PoolQC`Fence`MiscFeature`MiscVal`MoSold`YrSold`SaleType`SaleCondition`SalePrice;
colstr:"SSSSISSSSSSSSSSSSSSIISSSSSISSSSSSSISIIISSSSIIIIIIIIIISISISSISIISSSIIIIIISSSIIISS";

/ Read train data set from disk
colstrt:colstr,"I";
.Q.fs[{`train insert flip colnames!(colstrt;",")0:x}]`:train.csv;

/ Skip header row
ds:train[1+til (-1+count train)];
cleandataset["train"];

/ Show the cleaned dataset
show "Train cleaned up dataset";
show train;

/ Start training regression model
train:([]
    intercept:(count train)#1.0),'train
cls:cols train;
    f:flip 0^"f"$train[cls[where (cls<>`SalePrice)]
    ];

w:"f"$((count f[0]),1)#(10000),(-1+count f[0])#0.0;
op:0^"f"$train[`SalePrice];

trainmodel:{[]
    tl:"f"$1.0e+009;
    s::"f"$1.0e-12;
    l2_p::0.0;
    counter:0;
    niter::100;
    show "Calling ridge regression";
    ridgeregression[f;op;tl;s;counter];
    };
 
/ Process test data
colnames:colnames[where colnames <>`SalePrice];
.Q.fs[{`test insert flip colnames!(colstr;",")0:x}]`:test.csv;
ds:test[1+til(-1+count test)]; 

/ Skip hearder row
testId:test[1+til(-1+count test)][`Id];
cleandataset["test"];

/ Show the cleaned dataset
show "Test cleaned up dataset";
show test;

/ Run regression model with trained weights on test data
finaloutput:{[]
    test::([]intercept:(count test)#1.0),'test;
    l:cols train;k:raze where each l =/: cols test;
    cls:l[k];
    wts:w[k];
    h:((count cls),1)# raze over (cls!wts)@cls;
    f:flip 0f^/:"f"$test[cls];
    o:f$h;
    show "Outputs :";
    show op:([]Id:testId;SalePrice:o);
    };

trainmodel[]; 
finaloutput[];
