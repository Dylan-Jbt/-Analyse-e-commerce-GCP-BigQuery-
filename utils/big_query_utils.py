from google.cloud import bigquery
import pandas as pd

class BigQueryHelper:
    def __init__(self, project_id: str):
        self.client = bigquery.Client(project=project_id)

    def run_query(self, sql: str) -> pd.DataFrame:
        """Exécute une requête SQL et renvoie un DataFrame pandas."""
        df = self.client.query(sql).to_dataframe()
        return df

    def save_to_csv(self, df: pd.DataFrame, filepath: str):
        """Sauvegarde le DataFrame en CSV."""
        df.to_csv(filepath, index=False)
        print(f"CSV sauvegardé : {filepath}")

