/ Ridge l2 regression
ridgeregression:{[f; op; tl; s; counter]niter {
    w::w - s * ((2 * (flip f)$((f$w) - op)) + (2 * l2_p * w))} \ counter;
    };

/ Clean the dataset.
/ @param  datasettype - string
cleandataset:{[datasettype]
    dataset::delete Id from dataset;
    
    / Change 1stFlrSF, 2ndFlrSF, and 3SsnPorch to q-type variables
    t:key ft:flip dataset;
    t[where t=`1stFlrSF]:`FstFlrSF;
    t[where t=`2ndFlrSF]:`SndFlrSF;
    t[where t=`3SsnPorch]:`ThreeSnPorch;
    dataset::flip t!value ft;

    / Non-categorical columns, not to be passed for one-hot encoding
    tokencolumns:`YearBuilt`YearRemodAdd`LotArea`MasVnrArea`BsmtFinSF1`BsmtFinSF2`BsmtUnfSF`TotalBsmtSF`FstFlrSF`SndFlrSF`LowQualFinSF`GrLivArea`BsmtFullBath`BsmtHalfBath`FullBath`HalfBath`BedroomAbvGr`KitchenAbvGr`TotRmsAbvGrd`Fireplaces`GarageYrBlt`GarageCars`GarageArea`WoodDeckSF`OpenPorchSF`EnclosedPorch`ThreeSnPorch`ScreenPorch`PoolArea`MiscVal`MoSold`YrSold`SalePrice;
    
    / If it is test dataset remove the SalePrice column
    if[datasettype like "test";tokencolumns:tokencolumns[where tokencolumns<>`SalePrice]];
    
    / Remove all non-cat columns from list, 
    / so we're sending only cats to one-hot
    tmp:cols dataset;
    tmp:tmp[where not tmp in\: tokencolumns];

    / Find all categorical columns with NAs, 
    / remove NAs and create a dict with distinct values in each column
    kna:k[wk:where (`NA in/: k:distinct each dataset[tmp])];
    t:0,(+\)t[til(-1 + count t:count each where each `NA <> kna)];
    rkna:raze kna;
    e:(tmp)[wk] ! t cut rkna[where rkna <> `NA];
    k[wk]:e@(tmp)[wk];
    k:(tmp) ! k;

    i:0;
    while[i < count k;
        dataset::dataset,'((`$( string (key k)[i]) ,/: string (value k)[i])!) each s:((count dataset),(count r:where each (value k)[i] =\: dataset[key k][i]))#0;
        s[r[i];i]:1;
        i:i+1;
    ];

    / Delete original non-one-hot categorical columns
    dataset::![dataset;();0b;tmp];

    / Re-append non-categorical columns
    dataset::dataset,'flip tokencolumns ! dataset[tokencolumns];

    / Create a alias to cleaned up datased
    $[datasettype like "train"; train::dataset; test::dataset]
    
    };

/ Train model function
trainmodel:{[]
    tl:"f"$1.0e+009;
    s::"f"$1.0e-12;
    l2_p::0.0;
    counter:0;
    niter::100;
    show "Calling ridge regression";
    ridgeregression[f; op; tl; s; counter];
    };

/ Run regression model with trained weights on test data
finaloutput:{[]
    test::([]intercept:(count test)#1.0),'test;
    l:cols train;
    k:raze where each l =/: cols test;
    cls:l[k];
    wts:w[k];
    h:((count cls),1)# raze over (cls!wts)@cls;
    f:flip 0f^/:"f"$test[cls];
    o:f$h;
    show "Results :";
    show op:([]Id:testId;SalePrice:o);
    };

/ Columns names
columns:`Id`MSSubClass`MSZoning`LotFrontage`LotArea`Street`Alley`LotShape`LandContour`Utilities`LotConfig`LandSlope`Neighborhood`Condition1`Condition2`BldgType`HouseStyle`OverallQual`OverallCond`YearBuilt`YearRemodAdd`RoofStyle`RoofMatl`Exterior1st`Exterior2nd`MasVnrType`MasVnrArea`ExterQual`ExterCond`Foundation`BsmtQual`BsmtCond`BsmtExposure`BsmtFinType1`BsmtFinSF1`BsmtFinType2`BsmtFinSF2`BsmtUnfSF`TotalBsmtSF`Heating`HeatingQC`CentralAir`Electrical`1stFlrSF`2ndFlrSF`LowQualFinSF`GrLivArea`BsmtFullBath`BsmtHalfBath`FullBath`HalfBath`BedroomAbvGr`KitchenAbvGr`KitchenQual`TotRmsAbvGrd`Functional`Fireplaces`FireplaceQu`GarageType`GarageYrBlt`GarageFinish`GarageCars`GarageArea`GarageQual`GarageCond`PavedDrive`WoodDeckSF`OpenPorchSF`EnclosedPorch`3SsnPorch`ScreenPorch`PoolArea`PoolQC`Fence`MiscFeature`MiscVal`MoSold`YrSold`SaleType`SaleCondition`SalePrice;
columnstypemask:"SSSSISSSSSSSSSSSSSSIISSSSSISSSSSSSISIIISSSSIIIIIIIIIISISISSISIISSSIIIIIISSSIIISS";

/ Read train data set from disk
columnstypemaskt:columnstypemask,"I";
.Q.fs[{`train insert flip columns!(columnstypemaskt;",")0:x}]`:train.csv;

/ Skip header row
dataset:train[1+til (-1 + count train)];
cleandataset["train"];

/ Show the cleaned dataset
show "Train cleaned up dataset";
show train;

/ Start training regression model
train:([]
    intercept:(count train)#1.0),'train;
    cls:cols train;
    f:flip 0^"f"$train[cls[where (cls<>`SalePrice)]
    ];

w:"f"$((count f[0]),1)#(10000),(-1 + count f[0])#0.0;
op:0^"f"$train[`SalePrice];
 
/ Process test data
/ Remove the SalePrice column
columns:columns[where columns <>`SalePrice];
.Q.fs[{`test insert flip columns!(columnstypemask;",")0:x}]`:test.csv;
dataset:test[1 + til(-1 + count test)]; 

/ Skip hearder row
testId:test[1+til(-1+count test)][`Id];
cleandataset["test"];

/ Show the cleaned dataset
show "Test cleaned up dataset";
show test;

trainmodel[]; 
finaloutput[];