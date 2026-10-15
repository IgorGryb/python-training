from pathlib import Path
import sys,json,hashlib,platform,shutil
sys.path.insert(0,'/tmp/ml-python')
import numpy as np,pandas as pd,sklearn
from sklearn.model_selection import GroupShuffleSplit,GroupKFold,cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score,confusion_matrix,classification_report
b=Path(__file__).resolve().parents[1]
d=pd.read_csv(b/'Data/pml-training.csv',na_values=['NA','#DIV/0!','']);test=pd.read_csv(b/'Data/pml-testing.csv',na_values=['NA','#DIV/0!',''])
meta=['Unnamed: 0','X','user_name','raw_timestamp_part_1','raw_timestamp_part_2','cvtd_timestamp','new_window','num_window','classe']
features=[c for c in d if c not in meta and d[c].isna().mean()<.05 and pd.api.types.is_numeric_dtype(d[c]) and d[c].nunique()>1]
X=d[features];y=d.classe;groups=d.user_name.astype(str)+'_'+d.num_window.astype(str)
train_idx,val_idx=next(GroupShuffleSplit(n_splits=1,test_size=.25,random_state=20261015).split(X,y,groups))
assert set(groups.iloc[train_idx]).isdisjoint(set(groups.iloc[val_idx]));assert X.isna().sum().sum()==0;assert test[features].isna().sum().sum()==0
xtr=X.iloc[train_idx];ytr=y.iloc[train_idx];xval=X.iloc[val_idx];yval=y.iloc[val_idx]
cv=GroupKFold(n_splits=3)
models={'Decision tree':DecisionTreeClassifier(random_state=20261015),'Random forest':RandomForestClassifier(n_estimators=150,max_features='sqrt',random_state=20261015,n_jobs=4)}
results={}
for name,model in models.items():
 scores=cross_val_score(model,xtr,ytr,groups=groups.iloc[train_idx],cv=cv,scoring='accuracy',n_jobs=1)
 results[name]={'cv_accuracy':scores.tolist(),'cv_mean':float(scores.mean())};print(name,results[name],flush=True)
name=max(results,key=lambda n:results[n]['cv_mean']);model=models[name];model.fit(xtr,ytr);pred=model.predict(xval);acc=accuracy_score(yval,pred);errors=int((pred!=yval).sum());N=len(yval)
z=1.96;p=errors/N;den=1+z*z/N;center=(p+z*z/(2*N))/den;half=z*np.sqrt(p*(1-p)/N+z*z/(4*N*N))/den
out={'rows':len(d),'test_rows':len(test),'features':features,'n_features':len(features),'development_rows':len(train_idx),'validation_rows':N,'groups':int(groups.nunique()),'development_groups':int(groups.iloc[train_idx].nunique()),'validation_groups':int(groups.iloc[val_idx].nunique()),'models':results,'selected':name,'validation_accuracy':float(acc),'validation_errors':errors,'validation_error_rate':p,'row_wilson_95_error_interval':[float(center-half),float(center+half)],'confusion_matrix':confusion_matrix(yval,pred,labels=list('ABCDE')).tolist(),'class_counts':y.value_counts().sort_index().to_dict(),'versions':{'python':platform.python_version(),'numpy':np.__version__,'pandas':pd.__version__,'sklearn':sklearn.__version__}}
print(json.dumps(out,indent=2),flush=True)
pd.DataFrame({'row_index':np.arange(len(d)),'group':groups,'split':np.where(np.isin(np.arange(len(d)),val_idx),'validation','development')}).to_csv(b/'Data/split_assignments.csv',index=False)
pd.DataFrame(out['confusion_matrix'],index=list('ABCDE'),columns=list('ABCDE')).to_csv(b/'Reports/Confusion_matrix.csv')
(b/'Reports/Classification_report.txt').write_text(classification_report(yval,pred,digits=5))
final=RandomForestClassifier(n_estimators=300,max_features='sqrt',random_state=20261015,n_jobs=4) if name=='Random forest' else models[name]
final.fit(X,y);pred20=final.predict(test[features]);pd.DataFrame({'problem_id':test.problem_id,'prediction':pred20}).to_csv(b/'Reports/Test_predictions.csv',index=False)
pd.DataFrame({'feature':features,'importance':final.feature_importances_}).sort_values('importance',ascending=False).to_csv(b/'Reports/Feature_importance.csv',index=False)
out['test_predictions']=pred20.tolist();out['final_n_trees']=300 if name=='Random forest' else 1
(b/'Reports/Results.json').write_text(json.dumps(out,indent=2));(b/'Code/requirements.txt').write_text('\n'.join(k+'=='+v for k,v in out['versions'].items() if k!='python')+'\nMarkdown\n')
print('DONE',flush=True)
