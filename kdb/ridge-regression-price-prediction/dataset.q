/*****************************************************************************
/*                                                                           *
/*                       Machine Learning API Framework                      *
/*                                                                           *
/*****************************************************************************
//
//  File Name:  dataset.q
//
//  Purpose:    This module applies ridge regression to a dataset
//
//  Author:     Joel Oliveira, First Derivatives
//
//  Revision History
//
//  Date        Author              Description
//  -------     ------------------  -----------------------------------------
//  15Aug17     Joel Oliveira       Original version

// Columns type mask
columnsTypeMask:"SSSSISSSSSSSSSSSSSSIISSSSSISSSSSSSISIIISSSSIIIIIIIIIISISISSISIISSSIIIIIISSSIIISS";

// Load the train dataset
loadTrainDataset:{[]

    // Load train dataset from disk
    columnsTypeMaskT::columnsTypeMask,"I";
    dataset::(columnsTypeMaskT; enlist ",")0:`:train.csv;
    
    // Clean the dataset
    cleanDataset "train";    

    // Show the cleaned dataset
    show "Train cleaned up dataset";
    show train;

    }

// Load the test dataset
loadTestDataset:{[]

    // Load the test dataset from the disk
    dataset::(columnsTypeMask; enlist ",")0:`:test.csv;
    
    // Get id column
    testId::dataset[1+til(count dataset)][`Id];

    cleanDataset "test" ;

    // Show the cleaned dataset
    show "Test cleaned up dataset";
    show test;

    }

// Clean the dataset.
// @param  datasetType - string ("train" or "test")
cleanDataset:{[datasetType]
    
    // Delete the Id column
    dataset::delete Id from dataset; 

    t:cols dataset;   

    // Change 1stFlrSF, 2ndFlrSF, and 3SsnPorch to q-type variables
    t[where t=`1stFlrSF]:`FstFlrSF;
    t[where t=`2ndFlrSF]:`SndFlrSF;
    t[where t=`3SsnPorch]:`ThreeSnPorch;
    
    dataset::t xcol dataset;

    // Non categorical columns, not to be passed for one hot encoding
    tokenColumns:`YearBuilt`YearRemodAdd`LotArea`MasVnrArea`BsmtFinSF1`BsmtFinSF2`BsmtUnfSF`TotalBsmtSF`FstFlrSF`SndFlrSF`LowQualFinSF`GrLivArea`BsmtFullBath`BsmtHalfBath`FullBath`HalfBath`BedroomAbvGr`KitchenAbvGr`TotRmsAbvGrd`Fireplaces`GarageYrBlt`GarageCars`GarageArea`WoodDeckSF`OpenPorchSF`EnclosedPorch`ThreeSnPorch`ScreenPorch`PoolArea`MiscVal`MoSold`YrSold`SalePrice;
    
    // If it is test dataset remove the SalePrice column
    tokenColumns:tokenColumns except $[datasetType~"test";`SalePrice;`];

    // Remove all non cat columns from list, 
    // so we are sending only cats to one hot
    tmp:(cols dataset)[where not (cols dataset) in\: tokenColumns];

    // Find all categorical columns with NAs, 
    // remove NAs and create a dict with distinct values in each column
    kna:k[wk:where (`NA in/:k:distinct each dataset[tmp])];
    t:0,(+\)t til -1+count t:count each where each `NA<>kna;
    rkna:raze kna;
    e:(tmp)[wk]!t cut rkna[where rkna<>`NA]; /! spaces
    k[wk]:e@(tmp)[wk];
    k:(tmp) ! k;
    
    {[k;i]
        dataset::dataset,'((`$( string (key k)[i]) ,/: string (value k)[i])!) each s:((count dataset),(count r: where each (value k)[i] =\: dataset[key k][i]))#0;
        }[k;] each til count k;

    // Delete original non one hot categorical columns
    dataset::![dataset;();0b;tmp];

    // Create a alias to cleaned up datased
    $[datasetType like "train"; train::dataset; test::dataset]
    
    };
